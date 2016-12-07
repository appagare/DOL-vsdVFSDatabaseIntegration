Option Strict On
Option Explicit On 

Imports System.ServiceProcess
Imports WA.DOL.LogEvent.LogEvent
Imports WA.DOL.Data
Imports System.Threading
Imports System.Data.SqlClient

Public Class vsdVFSDatabaseIntegration
    Inherits System.ServiceProcess.ServiceBase

    'db connection paramaters
    Private DBConnectRetryDelay As Integer = 30 'delay 30 sec. between initial DB connect attempts unless specified in app.config
    Private DBConnectRetryMax As Integer = 0 'try to obtain DB parameters indefinitely unless specified in app.config
    Private ThreadCount As Integer = 0 'number of threads spawned
    Private LogEventObject As New WA.DOL.LogEvent.LogEvent 'common LogEvent object
    Private DataObject As WA.DOL.Data.SqlHelper 'common Data object
    Private ConfigValues As New ConfigValues 'common class to hold all of the common runtime parameters

    'enumeration for state of the service
    Private Enum ServiceStates
        Shutdown = 0
        Paused = 1
        Running = 2
    End Enum
    Private ServiceState As ServiceStates = ServiceStates.Paused

#Region " Component Designer generated code "

    Public Sub New()
        MyBase.New()

        ' This call is required by the Component Designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call

    End Sub

    'UserService overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    ' The main entry point for the process
    <MTAThread()> _
    Shared Sub Main()
        Dim ServicesToRun() As System.ServiceProcess.ServiceBase

        ' More than one NT Service may run within the same process. To add
        ' another service to this process, change the following line to
        ' create a second service object. For example,
        '
        '   ServicesToRun = New System.ServiceProcess.ServiceBase () {New Service1, New MySecondUserService}
        '
        ServicesToRun = New System.ServiceProcess.ServiceBase() {New vsdVFSDatabaseIntegration}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    ' NOTE: The following procedure is required by the Component Designer
    ' It can be modified using the Component Designer.  
    ' Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        '
        'vsdVFSDatabaseIntegration
        '
        Me.ServiceName = "vsdVFSDatabaseIntegration"

    End Sub

#End Region

    Protected Overrides Sub OnStart(ByVal args() As String)
        ' Add code here to start your service. This method should set things
        ' in motion so your service can do its work.

        Try
            'read the basic operating parameters
            ReadAppSettings()

        Catch ex As Exception

            'LogEvent, Send E-mail, and quit
            Dim strMessage As String = "Service is unable to proceed. Shutting down. " & ex.Message
            'log the error
            LogEvent("Service_OnStart", strMessage, MessageType.Error, LogType.Standard)

            'initiate stop process
            InitiateStop()
            Exit Sub
        End Try

        'start an endless loop for service processing the queue
        ThreadPool.QueueUserWorkItem(AddressOf ServiceRun)
    End Sub

    Protected Overrides Sub OnStop()
        ' Add code here to perform any tear-down necessary to stop your service.
        'warn threads we are shutting down
        ServiceState = ServiceStates.Shutdown

        'log the fact that we are "starting to stop"
        LogEvent("OnStop", "Begin OnStop", MessageType.Information, LogType.Standard)

        'give threads up to Delay seconds to wrap things up (note - delay is in milliseconds)
        Dim dtEndWait As Date = Now.AddMilliseconds(ConfigValues.Delay)
        While Now <= dtEndWait
            If ThreadCount = 0 Then
                Exit While
            End If
        End While

        'log event that we have stopped
        LogEvent("OnStop", "Service Stopped", MessageType.Finish, LogType.Standard)

        LogEventObject = Nothing
        ConfigValues = Nothing
    End Sub

    Protected Overrides Sub OnShutdown()
        'calls the Windows service OnStop method with the OS shuts down.
        OnStop()
    End Sub

    'commented out for ThreadSafety
    '''' <summary>
    ''''     Initializes the parameter array for the thread (should only happen once)
    '''' </summary>
    '''' <param name="Table">Datatable containing the fields.</param>
    '''' <param name="Parameters">Array of parameters being initialized.</param>
    'Private Sub InitializeParameterArray(ByVal Table As DataTable, ByRef Parameters() As SqlClient.SqlParameter)
    '    Dim intIdx As Integer = 0
    '    ReDim Parameters(Table.Columns.Count - 1)
    '    For intIdx = 0 To Table.Columns.Count - 1
    '        If Left(Table.Columns(intIdx).ColumnName, 1) = "@" Then
    '            'only grab fields that indicate they are SP parameters
    '            Parameters(intIdx) = New SqlClient.SqlParameter
    '            Parameters(intIdx).ParameterName = "@" & Table.Columns(intIdx).ColumnName
    '            Parameters(intIdx).Value = ""
    '        End If
    '    Next
    'End Sub
    ''' <summary>
    '''     Programmatically stop the main thread if we've already started up
    '''     such as during the database connection
    ''' </summary>
    Private Sub InitiateStop()
        Dim sc As New ServiceController(Me.ServiceName)
        sc.Stop()
        sc = Nothing
    End Sub
    ''' <summary>
    '''     Common code for writing an event to the event log database of the specified type.
    ''' </summary>
    ''' <param name="Source">source procedure reporting the event.</param>
    ''' <param name="Message">actual event message.</param>
    ''' <param name="MessageType">LogEvent object indicator specifying whether the message is error, informational, start, finish, or debug.</param>
    ''' <param name="LogType">LogEvent object indicator specifying the type of event to log (Standard, E-mail, etc.)</param>
    ''' <param name="ForceEmail">Forces an e-mail to be sent, regardless of error type or whether or </param>
    ''' <remarks>
    '''     When a LogType is error, an e-mail may be automatically sent. To avoid flooding the AppSupport Inbox, e-mails 
    '''     are only sent once every ConfigValues.EmailFrequency seconds UNLESS the ForceEmail flag is set.
    ''' </remarks>
    Private Sub LogEvent(ByVal Source As String, _
        ByVal Message As String, _
        ByVal MessageType As MessageType, _
        ByVal LogType As LogType, _
        Optional ByVal ForceEmail As Boolean = False)

        'log message
        LogEventObject.LogEvent(Me.ServiceName, Source, Message, MessageType, LogType)

        'if message type is an error, also log an e-mail event if we haven't sent one in awhile
        If ForceEmail = True Or (MessageType = MessageType.Error AndAlso Now >= ConfigValues.LastEmailSent.AddSeconds(ConfigValues.EmailFrequency)) Then

            'send the e-mail
            LogEventObject.LogEvent(Me.ServiceName, Source, Message, MessageType, LogType.Email)

            'update the last email sent time
            ConfigValues.LastEmailSent = Now
        End If
    End Sub

    ''' <summary>
    '''     Worker thread to process the records.
    ''' </summary>
    ''' <param name="State">New thread callback. State contains the TranType</param>
    ''' <remarks>
    '''     This runs in a continuous loop until the service is stopped.
    '''     Multiple threads are spawned, one for each TranType. The thread will sleep when no messages are 
    '''     found or when an error occurs.
    ''' </remarks>
    Private Sub ProcessRecords(ByVal State As Object)

        Const SOURCE_KEY_IDX As Integer = 0 ' required by View AND updated to Field System
        Const DELIVERY_KEY_IDX As Integer = 1 ' required by View AND updated to Field System

        Dim cmdParameters() As SqlClient.SqlParameter

        If ConfigValues.DebugMode > 2 Then
            Me.LogEvent("ProcessRecords", "Starting thread (" & CType(State, String) & ")", MessageType.Debug, LogType.Standard, False)
        End If

        Try
            'create an instance of the TranTypeUtil class for this thread
            Dim TranTypeUtil As New TranTypeUtility(CType(State, String), ConfigValues.TranTypes)

            While ServiceState = ServiceStates.Running
                Dim Records As New DataTable 'table of records needing integration
                Dim r As DataRow

                'extra debugging
                If ConfigValues.DebugMode > 2 Then
                    Me.LogEvent("ProcessRecords", "Loop (" & CType(State, String) & ")", MessageType.Debug, LogType.Standard, False)
                End If

                Try
                    'get the records
                    Records = DataObject.ExecuteDataset(TranTypeUtil.SourceConnectStringKey, CommandType.StoredProcedure, TranTypeUtil.SourceSelectName).Tables(0)

                    'initialize the parameter array
                    If cmdParameters Is Nothing Then

                        Dim intIdx As Integer = 0
                        'ReDim cmdParameters(Records.Columns.Count - 1)
                        ReDim cmdParameters(0)

                        For intIdx = 0 To Records.Columns.Count - 1
                            If Left(Records.Columns(intIdx).ColumnName, 1) = "@" Then
                                'only grab fields that indicate they are SP parameters
                                If Not cmdParameters(UBound(cmdParameters)) Is Nothing Then  'intIdx > 0 Then
                                    'create a slot in our collection if necessary
                                    ReDim Preserve cmdParameters(UBound(cmdParameters) + 1)
                                End If
                                cmdParameters(UBound(cmdParameters)) = New SqlClient.SqlParameter
                                cmdParameters(UBound(cmdParameters)).ParameterName = Records.Columns(intIdx).ColumnName
                                cmdParameters(UBound(cmdParameters)).Value = ""
                            End If
                        Next 'each column
                    End If 'cmdParameters = nothing

                Catch ex As Exception
                    'this could be a permissions or connection problem with the database or some larger issue
                    'regardless, log the event and sleep
                    Me.LogEvent("ProcessRecords", "Error on thread " & CType(State, String) & " preparing to read data. " & ex.Message, MessageType.Error, LogType.Standard, False)
                    GoTo SleepThread
                End Try

                For Each r In Records.Rows

                    Dim strStep As String = ""
                    Dim datStartTime As Date = Now 'capture the start time of this record for Interface Stats

                    'extra debugging
                    If ConfigValues.DebugMode > 2 Then
                        Me.LogEvent("ProcessRecords", "Record (" & CType(State, String) & ")", MessageType.Debug, LogType.Standard, False)
                    End If

                    Try

                        'set parameters
                        Dim p As SqlClient.SqlParameter
                        For Each p In cmdParameters
                            If Not p Is Nothing Then
                                'some columns in the table don't create parameters so 
                                p.Value = r(p.ParameterName)
                            End If
                        Next

                        ' insert Delivery Key (if necessary) ROS does not use this
                        If TranTypeUtil.DeliveryKeySelectName <> "" AndAlso CType(r(DELIVERY_KEY_IDX), String) <> "" Then
                            strStep = " inserting Delivery Key for record (" & CType(r(SOURCE_KEY_IDX), String) & "). "
                            DataObject.ExecuteNonQuery(TranTypeUtil.DestinationConnectStringKey, CommandType.StoredProcedure, _
                                TranTypeUtil.DeliveryKeySelectName, _
                                New SqlClient.SqlParameter(TranTypeUtil.DeliveryKeyParamName, r(DELIVERY_KEY_IDX)))
                        End If

                        ' insert integration
                        strStep = " inserting record (" & CType(r(SOURCE_KEY_IDX), String) & "). "
                        DataObject.ExecuteNonQuery(TranTypeUtil.DestinationConnectStringKey, CommandType.StoredProcedure, _
                                                    TranTypeUtil.DestinationInsertName, _
                                                    cmdParameters)

                        ' update IPO source
                        strStep = " updating record (" & CType(r(SOURCE_KEY_IDX), String) & "). "
                        DataObject.ExecuteNonQuery(TranTypeUtil.SourceConnectStringKey, CommandType.StoredProcedure, _
                            TranTypeUtil.SourceUpdateName, _
                            New SqlClient.SqlParameter(TranTypeUtil.SourceKeyName, r(SOURCE_KEY_IDX)), _
                            New SqlClient.SqlParameter(TranTypeUtil.SourceUpdateParamName, datStartTime))


                    Catch ex As Exception
                        'error processing record - treat as recoverable but sleep all threads
                        Me.LogEvent("ProcessRecords", "Error on thread " & CType(State, String) & " while " & strStep & ex.Message, MessageType.Error, LogType.Standard, False)

                        'stop processing this set of records
                        'we will fall into sleep after we exit the loop
                        Exit For 'exit For Next Each record,
                    End Try 'inner Try to 

                    If ServiceState <> ServiceStates.Running Then
                        'a request to shutdown the service has occured.
                        'bail out of the thread immediately
                        Records = Nothing
                        Exit While
                    End If
                Next 'each record

SleepThread:
                'no (more) records, night batch, or an error forced us here - sleep this thread
                Records = Nothing
                Thread.Sleep(ConfigValues.Delay)

            End While 'main loop - ServiceStates.Running

            TranTypeUtil = Nothing
        Catch ex As Exception
            'critical error - this aborts the thread
            Me.LogEvent("ProcessRecords", "Critical error starting thread (" & CType(State, String) & "). Transactions won't be integrated! " & _
            ex.Message, MessageType.Error, LogType.Standard, True)
        End Try

        'decrement the thread count
        Interlocked.Decrement(ThreadCount)

    End Sub
    ''' <summary>
    '''     Retrieve a single parameter from app.config.
    ''' </summary>
    ''' <param name="Key">The name of the key being retrieved.</param>
    Private Function ReadAppSetting(ByVal Key As String) As String

        On Error Resume Next
        Dim AppSettingsReader As New System.Configuration.AppSettingsReader
        Dim strReturnValue As String = ""
        Key = Trim(Key)
        If Key <> "" Then
            'get the value
            strReturnValue = CType(AppSettingsReader.GetValue(Key, GetType(System.String)), String)
        End If
        AppSettingsReader = Nothing
        Return strReturnValue
    End Function
    ''' <summary>
    '''     Reads the basic app.config values.
    ''' </summary>
    Private Sub ReadAppSettings()
        'Purpose:   Read the basic app.config settings

        'set mode equal to Service Name
        ConfigValues.ProcessMode = Me.ServiceName

        'get DB connect string key
        ConfigValues.ConnectionKey = ReadAppSetting("DatabaseKey") 'get connect string key

        'get DB connect delay
        If IsNumeric(ReadAppSetting("CriticalConnectionRetry")) AndAlso _
            CType(ReadAppSetting("CriticalConnectionRetry"), Integer) > 0 Then
            DBConnectRetryDelay = CType(ReadAppSetting("CriticalConnectionRetry"), Integer)
        End If

        'get DB connect max
        If IsNumeric(ReadAppSetting("CriticalConnectionRetryMax")) AndAlso _
            CType(ReadAppSetting("CriticalConnectionRetryMax"), Integer) > 0 Then
            DBConnectRetryMax = CType(ReadAppSetting("CriticalConnectionRetryMax"), Integer)
        End If

    End Sub
    ''' <summary>
    '''     Connect to the vsdVFSImmediateUpdate database to obtain the operating parameters.
    '''     This will try a pre-determined number of times as defined by the app.config file.
    ''' </summary>
    Private Sub ReadDBSettings()

        On Error Resume Next 'start local error handling to handle db connect retries

        Dim intDBConnectAttempt As Integer = 0 'db connect counter
        Dim dsSettings As New DataSet
        Dim r As DataRow
        Dim DBConnectOK As Boolean = False

        Do While DBConnectOK = False
            'get the db app. settings
            dsSettings = DataObject.ExecuteDataset(ConfigValues.ConnectionKey, CommandType.StoredProcedure, _
                "selAppConfig", New SqlClient.SqlParameter("@strProcess", ConfigValues.ProcessMode))

            If Err.Number = 0 Then
                'we were able to connect to the db, so we can retrieve the settings 
                DBConnectOK = True

                'LastEmailSent is initialized as an "old" day upon instantiation 
                'However, if the DB didn't connect on the first try, we may have sent an e-mail so 
                'reset the LastEmailSent value so any new transactions errors generate e-mails immediately
                ConfigValues.LastEmailSent = Now.AddDays(-1)

                On Error GoTo 0 'resume normal error handling. 
                'Any errors here should now bubble up the stack through ServiceRun 
                'to OnStart, log the fatal exception and initiate shutdown

                For Each r In dsSettings.Tables(0).Rows
                    'Me.LogEvent("debug", LCase(CType(r("Name"), String)) & "=" & CType(r("Value"), String), MessageType.Debug, LogType.Standard)
                    Select Case LCase(CType(r("Name"), String))
                        Case "debugmode"
                            ConfigValues.DebugMode = CType(r("Value"), Byte)

                        Case "delay"
                            ConfigValues.Delay = CType(r("Value"), Integer) * 1000 'in seconds

                        Case "emailfrequency"
                            ConfigValues.EmailFrequency = CType(r("Value"), Integer)

                        Case "vsipoconnectionkey"
                            ConfigValues.IPOConnectionKey = CType(r("Value"), String)
                    End Select
                Next

                'get the tran code to web service calls cross-reference
                ConfigValues.TranTypes = DataObject.ExecuteDataset(ConfigValues.ConnectionKey, CommandType.StoredProcedure, _
                    "selDBIntegrationTranTypes", New SqlClient.SqlParameter("@strProcess", ConfigValues.ProcessMode)).Tables(0)

                Exit Do 'not really necessary since DBConnectOK is now true
            Else
                'Test Case #1
                'error connecting to db; handle retry loop

                'increment our counter
                intDBConnectAttempt += 1

                'log an event (which will send an e-mail, if appropriate)
                LogEvent("ReadDBSettings", "Attempt " & intDBConnectAttempt.ToString & " - " & _
                    Err.Description, MessageType.Error, LogType.Standard)

                If DBConnectRetryMax > 0 AndAlso intDBConnectAttempt >= DBConnectRetryMax Then
                    'we have a DB connect attempt limit and which reached it.

                    On Error GoTo 0 'resume normal error handling. 
                    'Throw exception which should bubble up the stack through ServiceRun 
                    'to OnStart, log the fatal exception, and initiate shutdown.
                    Throw New Exception("Unable to connect to database after " & DBConnectRetryMax.ToString & " attempts.")
                    Exit Sub
                End If

                'sleep for awhile (DBConnectRetryDelay is in seconds, so multiply)
                Thread.Sleep(DBConnectRetryDelay * 1000)

            End If
        Loop ' DBConnectOK = False

    End Sub

    ''' <summary>
    '''     Main thread for the service.
    ''' </summary>
    ''' <param name="State">New thread callback.</param>
    ''' <remarks>
    '''     This runs in a continuous loop until the service is stopped.
    '''     Multiple threads are spawned for each message in the queue, up to the 
    '''     ConfigValue.MaxThreads value. The thread will sleep when no messages are 
    '''     found in the queue or when a recoverable error occurs.
    ''' </remarks>
    Protected Sub ServiceRun(ByVal State As Object)

        'make note that we have started
        LogEvent("ServiceRun", "Checking settings.", MessageType.Start, LogType.Standard)

        Dim r As DataRow
        Try

            'get the db settings
            ReadDBSettings()

            If ConfigValues.DebugMode > 2 Then
                'give time to attach a debugger
                Thread.Sleep(45000)
            End If

            'validate settings
            If ConfigValues.TranTypes.Rows.Count < 1 Then
                Throw New Exception("No TranTypes found for process [" & ConfigValues.ProcessMode & "]")
            End If

            'make note that we started
            LogEvent("ServiceRun", "Settings ok. Starting main loop.", MessageType.Start, LogType.Standard)

            'set our status to run mode
            ServiceState = ServiceStates.Running

            'spawn one thread per tran type
            For Each r In ConfigValues.TranTypes.Rows

                'increment the thread count (each thread will decrement this when its done)
                Interlocked.Increment(ThreadCount)

                'process each unique connect string key on a separate thread - pass in the TranType to the thread
                ThreadPool.QueueUserWorkItem(AddressOf ProcessRecords, r("TranType"))
            Next

            If ThreadCount = 0 Then
                'if no threads were able to start, throw an exception and shutdown
                Throw New Exception("No threads were able to start.")
            End If

        Catch ex As Exception

            'LogEvent, Send E-mail, and quit
            Dim strMessage As String = "Service is unable to proceed. Shutting down. " & ex.Message
            'log the error
            LogEvent("Service_OnStart", strMessage, MessageType.Error, LogType.Standard, True)

            'initiate stop process

            Dim sc As New ServiceController(Me.ServiceName)
            sc.Stop()
            Exit Sub
        End Try
    End Sub
End Class

''' <summary>
'''     This friend class contains all of the operating values required by the service and threads. The
'''     service populates this class once at startup.
''' </summary>
Friend Class ConfigValues

    Private _ConnectionKey As String = "" 'vsdVFSImmediateUpdate connection string key
    Private _DebugMode As Byte = 0 'debugging indicator
    Private _Delay As Integer = 30000 'number of milliseconds to pause the process when a recoverable error occurs
    Private _EmailFrequency As Integer = 900 'number of seconds between error e-mails (db setting updates this value)
    Private _IPOConnectionKey As String = "" 'connection string key used for the Message Processor when checking for VFS availability
    Private _LastEmailSent As Date = Now.AddDays(-1) 'initialize it to an "old" day
    Private _ProcessMode As String = "" 'included to allow multiple instances of the service if necessary

    Private _TranTypes As New DataTable 'table containing TranType cross reference info

    ''' <summary>
    '''     This property sets/returns the vsdVFSImmediateUpdate connection string key.
    ''' </summary>
    Friend Property ConnectionKey() As String
        Get
            Return _ConnectionKey
        End Get
        Set(ByVal Value As String)
            _ConnectionKey = Value
        End Set
    End Property
    ''' <summary>
    '''     This property sets/returns a debug logging value. 0 equals basic debugging. A value of 1 
    '''     equals extra debugging. A value of 2 will also log each message request/response value.
    ''' </summary>
    Friend Property DebugMode() As Byte
        Get
            Return _DebugMode
        End Get
        Set(ByVal Value As Byte)
            _DebugMode = Value
        End Set
    End Property
    ''' <summary>
    '''     This property sets/returns the number of milliseconds the main thread sleeps when a recoverable error occurs or there are no messages to process.
    ''' </summary>
    Friend Property Delay() As Integer
        Get
            Return _Delay
        End Get
        Set(ByVal Value As Integer)
            _Delay = Value
        End Set
    End Property
    ''' <summary>
    '''     This property sets/returns the number of seconds that should pass between e-mail error notifications.
    ''' </summary>
    Friend Property EmailFrequency() As Integer
        Get
            Return _EmailFrequency
        End Get
        Set(ByVal Value As Integer)
            _EmailFrequency = Value
        End Set
    End Property
    ''' <summary>
    '''     This property sets/returns the vsIPO connection string key (used for checking HP Availability).
    ''' </summary>
    Friend Property IPOConnectionKey() As String
        Get
            Return _IPOConnectionKey
        End Get
        Set(ByVal Value As String)
            _IPOConnectionKey = Value
        End Set
    End Property
    ''' <summary>
    '''     This property sets/returns the date that the last e-mail was sent.
    ''' </summary>
    Friend Property LastEmailSent() As Date
        Get
            Return _LastEmailSent
        End Get
        Set(ByVal Value As Date)
            _LastEmailSent = Value
        End Set
    End Property

    ''' <summary>
    '''     This property sets/returns the process name value.
    ''' </summary>
    Friend Property ProcessMode() As String
        Get
            Return _ProcessMode
        End Get
        Set(ByVal Value As String)
            _ProcessMode = Value
        End Set
    End Property

    ''' <summary>
    '''     This property contains the data table of TranTypes.
    ''' </summary>
    Friend Property TranTypes() As DataTable
        Get
            Return _TranTypes
        End Get
        Set(ByVal Value As DataTable)
            _TranTypes = Value
        End Set
    End Property

    Public Sub New()
    End Sub
End Class
