{
  (c) 2004 Directorate of New Technologies, Royal National Institute for Deaf people (RNID)

  The RNID licence covers this unit. Read the licence at:
      http://www.ictrnid.org.uk/docs/gw/rnid_license.txt

  This unit contains code written by:
    * Frank Shearar
}
unit TestIdNotification;

interface

uses
  IdInterfacedObject, IdNotification, SysUtils, TestFramework;

type
  IIdFoo = interface
    ['{0B189835-280E-41B6-9D93-EEDED5BA7EA3}']
    procedure Bar;
  end;

  TIdFoo = class(TIdInterfacedObject,
                 IIdFoo)
  private
    fBarCalled:   Boolean;
  public
    constructor Create;

    procedure Bar; virtual;

    property BarCalled: Boolean read fBarCalled;
  end;

  TIdCallBar = class(TIdNotification)
  public
    procedure Run(const Subject: IInterface); override;
  end;

  TIdRaiseException = class(TIdFoo)
  private
    fExceptClass: ExceptClass;
  public
    procedure Bar; override;

    property ExceptClass: ExceptClass read fExceptClass write fExceptClass;
  end;

  TIdSelfRemover = class(TIdFoo)
  private
    fObserved: TIdNotificationList;
  public
    procedure Bar; override;

    property Observed: TIdNotificationList read fObserved write fObserved;
  end;

  TestTIdNotificationList = class(TTestCase)
  private
    BarCaller: TIdCallBar;
    F1:        TIdFoo;
    F2:        TIdFoo;
    F3:        TIdFoo;
    F4:        TIdFoo;
    List:      TIdNotificationList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddRemoveCount;
    procedure TestAddNil;
    procedure TestAddListeners;
    procedure TestAssign;
    procedure TestAssignNonList;
    procedure TestNotify;
    procedure TestListenerRaisesException;
    procedure TestListSwallowsExpectedExceptions;
    procedure TestSelfRemovingListener;
  end;

implementation

uses
  Classes;

function Suite: ITestSuite;
begin
  Result := TTestSuite.Create('IdNotification unit tests');
  Result.AddTest(TestTIdNotificationList.Suite);
end;

//******************************************************************************
//* TIdFoo                                                                     *
//******************************************************************************
//* TIdFoo Public methods ******************************************************

constructor TIdFoo.Create;
begin
  inherited Create;

  Self.fBarCalled := false;
end;

//* TIdFoo Private methods *****************************************************

procedure TIdFoo.Bar;
begin
  Self.fBarCalled := true;
end;

//******************************************************************************
//* TIdCallBar                                                                 *
//******************************************************************************
//* TIdCallBar Public methods **************************************************

procedure TIdCallBar.Run(const Subject: IInterface);
begin
  (Subject as IIdFoo).Bar;
end;

//******************************************************************************
//* TIdRaiseException                                                          *
//******************************************************************************
//* TIdRaiseException Public methods *******************************************

procedure TIdRaiseException.Bar;
begin
  inherited Bar;

  raise Self.ExceptClass.Create(Self.ClassName + '.BlowUp');
end;

//******************************************************************************
//* TIdSelfRemover                                                             *
//******************************************************************************
//* TIdSelfRemover Public methods **********************************************

procedure TIdSelfRemover.Bar;
begin
  inherited Bar;

  Self.Observed.RemoveListener(Self);
end;

//******************************************************************************
//* TestTIdNotificationList                                                    *
//******************************************************************************
//* TestTIdNotificationList Public methods *************************************

procedure TestTIdNotificationList.SetUp;
begin
  inherited SetUp;

  Self.BarCaller := TIdCallBar.Create;
  Self.F1        := TIdFoo.Create;
  Self.F2        := TIdFoo.Create;
  Self.F3        := TIdFoo.Create;
  Self.F4        := TIdFoo.Create;
  Self.List      := TIdNotificationList.Create;
end;

procedure TestTIdNotificationList.TearDown;
begin
  Self.List.Free;
  Self.F4.Free;
  Self.F3.Free;
  Self.F2.Free;
  Self.F1.Free;
  Self.BarCaller.Free;

  inherited TearDown;
end;

//* TestTIdNotificationList Published methods **********************************

procedure TestTIdNotificationList.TestAddRemoveCount;
begin
  CheckEquals(0, Self.List.Count, 'Empty list');
  Self.List.AddListener(Self.F1);
  CheckEquals(1, Self.List.Count, '[F1]');
  Self.List.AddListener(Self.F2);
  CheckEquals(2, Self.List.Count, '[F1, F2]');

  Self.List.RemoveListener(Self.F1);
  CheckEquals(1, Self.List.Count, '[F2]');
  Self.List.RemoveListener(Self.F2);
  CheckEquals(0, Self.List.Count, 'Empty list again');
end;

procedure TestTIdNotificationList.TestAddNil;
begin
  Self.List.AddListener(nil);

  Self.List.Notify(Self.BarCaller);
end;

procedure TestTIdNotificationList.TestAddListeners;
var
  Other: TIdNotificationList;
begin
  Other := TIdNotificationList.Create;
  try
    Self.List.AddListener(Self.F1);
    Self.List.AddListener(Self.F2);
    Other.AddListener(Self.F3);
    Other.AddListener(Self.F4);

    Self.List.Add(Other);

    Self.List.Notify(Self.BarCaller);

    Check(Self.F1.BarCalled, 'Method not invoked on F1');
    Check(Self.F2.BarCalled, 'Method not invoked on F2');
    Check(Self.F3.BarCalled, 'Method not invoked on F3');
    Check(Self.F4.BarCalled, 'Method not invoked on F4');
  finally
    Other.Free;
  end;
end;

procedure TestTIdNotificationList.TestAssign;
var
  Other: TIdNotificationList;
begin
  Other := TIdNotificationList.Create;
  try
    Other.AddListener(Self.F1);
    Other.AddListener(Self.F2);
    Self.List.AddListener(Self.F3);
    Self.List.AddListener(Self.F4);

    Other.Assign(Self.List);

    Other.Notify(Self.BarCaller);

    Check(not Self.F1.BarCalled, 'Method invoked on F1 (Original list not cleared)');
    Check(not Self.F2.BarCalled, 'Method invoked on F2 (Original list not cleared)');
    Check(    Self.F3.BarCalled, 'Method not invoked on F3 (New list not added)');
    Check(    Self.F4.BarCalled, 'Method not invoked on F4 (New list not added)');
  finally
    Other.Free;
  end;
end;

procedure TestTIdNotificationList.TestAssignNonList;
var
  P: TPersistent;
begin
  P := TPersistent.Create;
  try
    Self.ExpectedException := EConvertError;
    Self.List.Assign(P);
  finally
    P.Free;
  end;
end;

procedure TestTIdNotificationList.TestNotify;
begin
  Self.List.AddListener(Self.F1);
  Self.List.AddListener(Self.F2);

  Self.List.Notify(Self.BarCaller);

  Check(Self.F1.BarCalled, 'Method not invoked on F1');
  Check(Self.F2.BarCalled, 'Method not invoked on F2');
end;

procedure TestTIdNotificationList.TestListenerRaisesException;
var
  Failure: TIdRaiseException;
begin
  Failure := TIdRaiseException.Create;
  try
    Failure.ExceptClass := EConvertError;

    Self.List.AddListener(Failure);

    try
      Self.List.Notify(Self.BarCaller);
      Fail('No exception raised');
    except
      on EConvertError do;
    end;
  finally
    Failure.Free;
  end;
end;

procedure TestTIdNotificationList.TestListSwallowsExpectedExceptions;
var
  Failure:       TIdRaiseException;
begin
  Failure := TIdRaiseException.Create;
  try
    Failure.ExceptClass := EConvertError;
    Self.List.AddExpectedException(Failure.ExceptClass);

    Self.List.AddListener(Failure);

    Self.List.Notify(Self.BarCaller);
  finally
    Failure.Free;
  end;
end;

procedure TestTIdNotificationList.TestSelfRemovingListener;
var
  Count:   Integer;
  Remover: TIdSelfRemover;
begin
  Remover := TIdSelfRemover.Create;
  try
    Remover.Observed := Self.List;
    Self.List.AddListener(Remover);

    Count := Self.List.Count;
    Self.List.Notify(Self.BarCaller);
    Check(Remover.BarCalled, 'Listener not notified');

    Check(Self.List.Count < Count, 'Listener didn''t remove itself');
  finally
    Remover.Free;
  end;
end;

initialization
  RegisterTest('SIP Notification mechanism tests', Suite);
end.
