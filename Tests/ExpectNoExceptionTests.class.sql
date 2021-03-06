EXEC tSQLt.NewTestClass 'ExpectNoExceptionTests';
GO
CREATE PROCEDURE ExpectNoExceptionTests.[test does not fail if no exception is encountered]
AS
BEGIN
  EXEC tSQLt.ExpectNoException;
END;
GO
CREATE PROCEDURE ExpectNoExceptionTests.[test tSQLt.ExpectNoException causes test with exception to fail ]
AS
BEGIN

    EXEC tSQLt.NewTestClass 'MyTestClass';
    EXEC('CREATE PROC MyTestClass.TestExpectingNoException AS EXEC tSQLt.ExpectNoException;RAISERROR(''testerror'',16,10);');

    EXEC tSQLt_testutil.AssertTestFails 'MyTestClass.TestExpectingNoException';
END;
GO
CREATE PROCEDURE ExpectNoExceptionTests.[test tSQLt.ExpectNoException includes error information in fail message ]
AS
BEGIN

    EXEC tSQLt.NewTestClass 'MyTestClass';
    EXEC('CREATE PROC MyTestClass.TestExpectingNoException AS EXEC tSQLt.ExpectNoException;RAISERROR(''test error message'',16,10);');

    DECLARE @ExpectedMessage NVARCHAR(MAX);
    DECLARE @ProductMajorVersion INT;
    EXEC @ProductMajorVersion = tSQLt.Private_GetSQLProductMajorVersion;

    SET @ExpectedMessage = 'Expected no error to be raised. Instead this error was encountered:'+CHAR(13)+CHAR(10)+
                           'test error message[[]16,10]{'+
                           CASE WHEN @ProductMajorVersion >= 14 THEN 'MyTestClass.' ELSE '' END+
                           'TestExpectingNoException,1}';
    EXEC tSQLt_testutil.AssertTestFails 'MyTestClass.TestExpectingNoException', @ExpectedMessage;
END;
GO

CREATE PROCEDURE ExpectNoExceptionTests.[test tSQLt.ExpectNoException includes additional message in fail message ]
AS
BEGIN

    EXEC tSQLt.NewTestClass 'MyTestClass';
    EXEC('CREATE PROC MyTestClass.TestExpectingNoException AS EXEC tSQLt.ExpectNoException @Message=''Additional Fail Message.'';RAISERROR(''test error message'',16,10);');

    DECLARE @ExpectedMessage NVARCHAR(MAX);
    SET @ExpectedMessage = 'Additional Fail Message. Expected no error to be raised. Instead %';
    EXEC tSQLt_testutil.AssertTestFails 'MyTestClass.TestExpectingNoException', @ExpectedMessage;
END;
GO
CREATE PROCEDURE ExpectNoExceptionTests.[test fails if called more then once]
AS
BEGIN
  EXEC tSQLt.NewTestClass 'MyTestClass';
  EXEC('CREATE PROC MyTestClass.TestExpectingNoException AS  EXEC tSQLt.ExpectNoException;EXEC tSQLt.ExpectNoException;');

  EXEC tSQLt_testutil.AssertTestErrors 'MyTestClass.TestExpectingNoException','Each test can only contain one call to tSQLt.ExpectNoException.%';
END;
GO
CREATE PROCEDURE ExpectNoExceptionTests.[test a ExpectNoException cannot follow an ExpectException]
AS
BEGIN
  EXEC tSQLt.NewTestClass 'MyTestClass';
  EXEC('CREATE PROC MyTestClass.TestExpectingNoException AS  EXEC tSQLt.ExpectException;EXEC tSQLt.ExpectNoException;');

  EXEC tSQLt_testutil.AssertTestErrors 'MyTestClass.TestExpectingNoException','tSQLt.ExpectNoException cannot follow tSQLt.ExpectException inside a single test.%';
END;
GO

