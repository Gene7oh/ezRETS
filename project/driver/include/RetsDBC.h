/*
 * Copyright (C) 2005-2008 National Association of REALTORS(R)
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
#ifndef RETSDBC_H
#define RETSDBC_H

#include <iosfwd>
#include <list>
#include <boost/shared_ptr.hpp>
#include "librets/protocol_forward.h"
#include "librets/http_forward.h"
#include "librets/error_forward.h"
#include "ezrets.h"
#include "ezretsfwd.h"
#include "AbstractHandle.h"
#include "DataSource.h"

namespace odbcrets
{
class RetsDBC : public AbstractHandle
{
  public:
    RetsDBC(RetsENV* env);
    ~RetsDBC();

    RetsENV* getEnv();

    EzLoggerPtr getLogger();

    SQLRETURN SQLAllocStmt(SQLHSTMT *StatementHandlePtr);
    SQLRETURN SQLFreeStmt(RetsSTMT* stmt, SQLUSMALLINT option);
    SQLRETURN SQLConnect(SQLCHAR *DataSource, SQLSMALLINT DataSourceLength,
                         SQLCHAR *UserName, SQLSMALLINT UserLength,
                         SQLCHAR *Authentication, SQLSMALLINT AuthLength);
    SQLRETURN SQLDisconnect();

    SQLRETURN SQLDriverConnect(
        SQLHWND WindowHandle, SQLCHAR* InConnectionString,
        SQLSMALLINT InStringLength, SQLCHAR* OutConnectionString,
        SQLSMALLINT BufferLength, SQLSMALLINT* OutStringLengthPtr,
        SQLUSMALLINT DriverCompletion);

    SQLRETURN SQLGetInfo(SQLUSMALLINT InfoType, SQLPOINTER InfoValue,
                         SQLSMALLINT BufferLength, SQLSMALLINT *StringLength);

    SQLRETURN SQLGetConnectAttr(SQLINTEGER Attribute, SQLPOINTER Value,
                                SQLINTEGER BufferLength,
                                SQLINTEGER *StringLength);

    librets::RetsSessionPtr getRetsSession();
    MetadataViewPtr getMetadataView();

    bool canBeFreed();

    virtual SQLRETURN diagConnectionName(
        SQLPOINTER DiagInfoPtr, SQLSMALLINT BufferLength,
        SQLSMALLINT *StringLengthPtr);
    virtual SQLRETURN diagServerName(
        SQLPOINTER DiagInfoPtr, SQLSMALLINT BufferLength,
        SQLSMALLINT *StringLengthPtr);

    // Rather than friending a ton of crap, let's just make the
    // DataSource public.  Until we find a reason this breaks.
    DataSource mDataSource;
  private:
    bool login();
    bool login(std::string user, std::string passwd);

    RetsENV* mEnv;
    MetadataViewPtr mMetadataViewPtr;
    librets::RetsSessionPtr mRetsSessionPtr;
    std::list<RetsSTMT*> mStatements;

    boost::shared_ptr<std::ostream> mRetsLogFile;
    boost::shared_ptr<librets::StreamHttpLogger> mRetsHttpLogger;
    boost::shared_ptr<librets::RetsErrorHandler> mRetsErrorHandler;
};
}

#endif /* RETSDBC_H */
/* Local Variables: */
/* mode: c++ */
/* End: */
