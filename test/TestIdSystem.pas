{
  (c) 2005 Directorate of New Technologies, Royal National Institute for Deaf people (RNID)

  The RNID licence covers this unit. Read the licence at:
      http://www.ictrnid.org.uk/docs/gw/rnid_license.txt

  This unit contains code written by:
    * Frank Shearar
}
unit TestIdSystem;

interface

uses
  IdSystem, TestFramework;

type
  // This suite currently only supports Windows (2000).
  TestFunctions = class(TTestCase)
  published
    procedure TestGetCurrentProcessId;
    procedure TestGetHostNameNoWinsock;
  end;

implementation

uses
  SysUtils, Windows, Winsock;

function Suite: ITestSuite;
begin
  Result := TTestSuite.Create('IdSystem unit tests');
  Result.AddTest(TestFunctions.Suite);
end;

//* TestFunctions Published methods ********************************************

procedure TestFunctions.TestGetCurrentProcessId;
begin
  CheckEquals(Windows.GetCurrentProcessId,
              IdSystem.GetCurrentProcessId,
              'GetCurrentProcessId');
end;

procedure TestFunctions.TestGetHostNameNoWinsock;
var
  Buf:       PAnsiChar;
  ErrorCode: Integer;
  Len:       Integer;
  RC:        Integer;
begin
  Len := 1000;
  GetMem(Buf, Len*Sizeof(AnsiChar));
  try
    RC := Winsock.gethostname(Buf, Len);

    if (RC <> 0) then begin
      ErrorCode := WSAGetLastError;
      Fail('gethostname failed: '
         + IntToStr(ErrorCode) + '(' + SysErrorMessage(ErrorCode) + ')');
    end;

    CheckEquals(Buf, IdSystem.GetHostName, 'GetHostName');
  finally
    FreeMem(Buf);
  end;
end;

initialization
  RegisterTest('System-specific functions', Suite);
end.
