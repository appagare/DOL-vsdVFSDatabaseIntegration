Option Strict On
Option Explicit On 

''' <summary>
'''     This is a helper class that handles all of the TranType specific tasks.
''' </summary>
Friend Class TranTypeUtility
    Private DataObject As WA.DOL.Data.SqlHelper 'common Data object
    
    Private _SrcConnectStringKey As String = "" 'source database connect string key
    Private _SPSelName As String = "" 'name of the proc. for fetching source records to be integrated
    Private _SPUpdName As String = "" 'name of the proc. for updating the source record upon successful integration
    Private _SPSelParamName As String = "" 'name of source database key name for locating record to update upon successful integration
    Private _SPUpdParamName As String = "" 'name of source database parameter name to update upon successful integration (for Interface Stats)
    Private _DstConnectStringKey As String = "" 'dest. database connect string key
    Private _SPSelDeliveryKeyName As String = "" 'name of the proc. for detecting the Delivery Key record in the dest. database
    Private _SPSelDeliveryKeyParamName As String = "" 'name of the parameter for the Delivery Key parameter
    Private _SPInsTransactionName As String = "" 'name of the stored proc used for inserting the integration record in the dest. database

    Private _TranType As String = ""
    Private _TranTypes As New DataTable

    ''' <summary>
    '''     Returns the DestinationConnectStringKey set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property DestinationConnectStringKey() As String
        Get
            Return _DstConnectStringKey
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPInsTransactionName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property DestinationInsertName() As String
        Get
            Return _SPInsTransactionName
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPSelDeliveryKeyParamName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property DeliveryKeyParamName() As String
        Get
            Return _SPSelDeliveryKeyParamName
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPSelDeliveryKeyName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property DeliveryKeySelectName() As String
        Get
            Return _SPSelDeliveryKeyName
        End Get
    End Property
    ''' <summary>
    '''     Returns the SourceConnectStringKey set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property SourceConnectStringKey() As String
        Get
            Return _SrcConnectStringKey
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPSelParamName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property SourceKeyName() As String
        Get
            Return _SPSelParamName
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPSelName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property SourceSelectName() As String
        Get
            Return _SPSelName
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPUpdName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property SourceUpdateName() As String
        Get
            Return _SPUpdName
        End Get
    End Property
    ''' <summary>
    '''     Returns the common SPUpdParamName set by the New constructor.
    ''' </summary>
    Friend ReadOnly Property SourceUpdateParamName() As String
        Get
            Return _SPUpdParamName
        End Get
    End Property
    ''' <summary>
    '''     Returns the TranType passed into the Constructor.
    ''' </summary>
    Friend ReadOnly Property TranType() As String
        Get
            Return _TranType
        End Get
    End Property

    Public Sub New(ByVal TranType As String, ByVal TranTypes As DataTable)
        'pass in the TranType table and filter on the desired tran code
        _TranTypes = CopyDatatable(TranTypes)
        _TranType = TranType
        _TranTypes.DefaultView.RowFilter = "TranType='" & TranType & "'"
        If _TranTypes.DefaultView.Count < 1 Then
            Throw New Exception("Unable to find TranType '" & TranType & "' in list.")
        End If

        _SrcConnectStringKey = CType(_TranTypes.DefaultView(0)("SourceConnectStringKey"), String)
        _SPSelName = CType(_TranTypes.DefaultView(0)("SPSelName"), String)
        _SPUpdName = CType(_TranTypes.DefaultView(0)("SPUpdName"), String)
        _SPSelParamName = CType(_TranTypes.DefaultView(0)("SPSelParamName"), String)
        _SPUpdParamName = CType(_TranTypes.DefaultView(0)("SPUpdParamName"), String)
        _DstConnectStringKey = CType(_TranTypes.DefaultView(0)("DestinationConnectStringKey"), String)
        _SPSelDeliveryKeyName = CType(_TranTypes.DefaultView(0)("SPSelDeliveryKeyName"), String)
        _SPSelDeliveryKeyParamName = CType(_TranTypes.DefaultView(0)("SPSelDeliveryKeyParamName"), String)
        _SPInsTransactionName = CType(_TranTypes.DefaultView(0)("SPInsTransactionName"), String)
    End Sub
    Private Function CopyDatatable(ByVal SrcTable As DataTable) As DataTable
        'create a true copy of the datatable so it behaves properly as a object passed ByVal
        Dim DstTable As New DataTable
        Dim SrcRow As DataRow
        Dim SrcCol As DataColumn

        DstTable = SrcTable.Clone
        For Each SrcRow In SrcTable.Rows
            Dim DstRow As DataRow
            DstRow = DstTable.NewRow()
            For Each SrcCol In SrcTable.Columns
                DstRow(SrcCol.ColumnName) = SrcRow(SrcCol.ColumnName)
            Next
            DstTable.Rows.Add(DstRow)
        Next
        'return 
        Return DstTable

    End Function

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub
End Class
