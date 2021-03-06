/*
 * Copyright (C) 2009,2011 National Association of REALTORS(R)
 *
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, provided that the above copyright notice(s) and this
 * permission notice appear in all copies of the Software and that
 * both the above copyright notice(s) and this permission notice
 * appear in supporting documentation.
 */

#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include "librets/util.h"
#include "librets/GetObjectResponse.h"
#include "librets/ObjectDescriptor.h"
#include "OnDemandObjectResultSet.h"
#include "OnDemandObjectQuery.h"
#include "Column.h"
#include "EzLogger.h"
#include "OdbcGetObjectException.h"
#include "str_stream.h"
#include "utils.h"
#include <stdexcept>
    
namespace b = boost;
namespace lu = librets::util;
using namespace odbcrets;
using namespace librets;
using std::string;

#define CLASS OnDemandObjectResultSet
CLASS::CLASS(EzLoggerPtr logger, MetadataViewPtr metadataView,
             DataTranslatorSPtr translator, AppRowDesc* ard)
    : ResultSet(logger, metadataView, translator, ard), mObjectResponse(NULL),
      mCurrentObject(NULL)
{
}

void CLASS::setObjectResponse(GetObjectResponse* response)
{
    mObjectResponse = response;
}

// Its not clear what value this should really have.  Since we use
// this to represtend the cached value as well as the runtime value.
// In SQLRowCount its defined as "do not count on this number as it
// can't be accurate until the data is received."  Until some testing
// is done, we will set this as 1.  If this ends up causing us a
// problem, we'll adjust it.  -1 also appears to be valid in some
// circumstances.
int CLASS::rowCount()
{
    return 1;
}

// We don't have any good way to check this in the OnDemand version of
// this class as this is a holdover from the vector based versions.
// As a result, we will also send false.  If there is truely no data,
// the hasNext() call will return false.  In the only case where this
// would matter hasNext() is called immedately after isEmpty() (in
// RetsSTMT::SQLFetch())
bool CLASS::isEmpty()
{
    return false;
}

bool CLASS::hasNext()
{
    if (mObjectResponse == NULL)
    {
        return false;
    }

    mCurrentObject = mObjectResponse->NextObject();

    if (mCurrentObject == NULL)
    {
        return false;
    }

    switch (mCurrentObject->GetRetsReplyCode())
    {
        case 20400:
        case 20401:
        case 20402:
        case 20406:
        case 20407:
        case 20408:
        case 20409:
        case 20410:
        case 20411:
        case 20412:
        case 20413:
        case 20414:
            throw OdbcGetObjectException(mCurrentObject->GetRetsReplyText());
            break;

        // <RETS ReplyCode="20403" ReplyText="No Object Found" />
        // In the case of a single image, we should probably also
        // return false.  But if this is a multiple, dropping out here
        // will negate the rest of the objects, which would be
        // bad. So, per 5.11.2 of the RETS 1.7.2 spec, the proper
        // course of action should be to just call ourselves/hasNext
        // again and hense skipping this no-object object. By the time
        // we hit this code segment, we'll already have returned false
        // if we were at "the end of the line."  (You may also be
        // asking why we don't do the same for the error conditions
        // above.  I consider those more critical errors that are
        // worth dropping processing for.)
        case 20403:
            return hasNext();
            break;

        default:
            break;
    }
            

    // Copy the ObjectResponse elements into a map so that we can
    // simulate the Data OnDemand stuff in how it handles columns.
    mObjectResponseMap.clear();
    mObjectResponseMap[OnDemandObjectQuery::OBJECT_KEY] =
        mCurrentObject->GetObjectKey();
    mObjectResponseMap[OnDemandObjectQuery::OBJECT_ID] =
        boost::lexical_cast<string>(mCurrentObject->GetObjectId());
    mObjectResponseMap[OnDemandObjectQuery::MIME_TYPE] =
        mCurrentObject->GetContentType();
    mObjectResponseMap[OnDemandObjectQuery::DESCRIPTION] =
        mCurrentObject->GetDescription();
    mObjectResponseMap[OnDemandObjectQuery::LOCATION_URL] =
        mCurrentObject->GetLocationUrl();

    // This could be the plaece for future optimization, I see this as
    // being potentially expensive in terms of memory and memory copy
    // time. It depends on how smart the underlying string from the
    // C++ library is.
    string obj;
    lu::readIntoString(mCurrentObject->GetDataStream(), obj);
    mObjectResponseMap[OnDemandObjectQuery::RAW_DATA] = obj;

    return true;
}

void CLASS::processNextRow()
{
    LOG_DEBUG(mLogger, "In OnDemandObjectResultSet::processNextRow()");

    ColumnVector::iterator i;
    int count = 0;
    for (i = mColumns->begin(); i != mColumns->end(); i++, count++)
    {
        ColumnPtr column = *i;
        string columnName = column->getName();
        string result;
        try
        {
            result = mObjectResponseMap[columnName];
        }
        catch (std::invalid_argument &e)
        {
            result = "";
            LOG_DEBUG(mLogger, str_stream() << e.what() << " -- ignoring");
        }

        SQLSMALLINT type = column->getDataType();
        if (type == SQL_LONGVARBINARY || type == SQL_BINARY ||
            type == SQL_VARBINARY)
        {
            LOG_DEBUG(mLogger, str_stream() << count << " " <<
                      column->getName() << ": [omitting possible binary data]");
        }
        else
        {
            LOG_DEBUG(mLogger, str_stream() << count << " " <<
                      column->getName() << ": " << result);
        }

        if (column->isBound())
        {
            column->setData(count, result);
        }
    }    
}

void CLASS::getData(SQLUSMALLINT colno, SQLSMALLINT TargetType,
                    SQLPOINTER TargetValue, SQLLEN BufferLength,
                    SQLLEN *StrLenorInd, DataStreamInfo *streamInfo)
{
    LOG_DEBUG(mLogger, "In OnDemandObjectResultSet::getData()");

    int rColno = colno - 1;
    ColumnPtr& column = mColumns->at(rColno);

    string result;
    try
    {
        result = mObjectResponseMap[column->getName()];
    }
    catch (std::invalid_argument &e)
    {
        result = "";
        LOG_DEBUG(mLogger, str_stream() << e.what() << " -- ignoring");
    }

    SQLSMALLINT type = column->getDataType();
    if (type == SQL_LONGVARBINARY || type == SQL_BINARY ||
        type == SQL_VARBINARY)
    {
        LOG_DEBUG(mLogger, str_stream() << column->getName() << " " <<
                  getTypeName(TargetType) <<
                  " [omitting possible binary data]");
    }
    else
    {
        LOG_DEBUG(mLogger, str_stream() << column->getName() << " " <<
                  getTypeName(TargetType) << " " << result);
    }

    column->setData(rColno, result, TargetType, TargetValue, BufferLength,
                    StrLenorInd, streamInfo);
}
