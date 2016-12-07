/*
todo: update DB name for QA

*/

use vsIPO
GO
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PAD_LEFT]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[PAD_LEFT]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PAD_RIGHT]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[PAD_RIGHT]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/*
	Pad a string a to a specific length with a particular padding character

*/
CREATE FUNCTION dbo.PAD_LEFT(@strIn varchar(255), @intTotalLen tinyint, @strPadChar char(1))
RETURNS varchar(255)
AS
BEGIN
	declare @strResult varchar(255)
 
	if @strIn is Null 
		begin
		        set @strIn = ''
		end
	
	if len(@strIn) < @intTotalLen
		begin
			-- pad left
			Set @strResult = right(Replicate(@strPadChar,@intTotalLen)+ @strIn,@intTotalLen) 
		end
	else 
		begin
			-- return the left @intTotalLen portion string
			Set @strResult = left(@strIn,@intTotalLen) 
		end

	return ( @strResult )
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*
	Pad a string to a specific length with a particular padding character

*/
CREATE FUNCTION dbo.PAD_RIGHT(@strIn varchar(255), @intTotalLen tinyint, @strPadChar char(1))
RETURNS varchar(255)
AS
BEGIN
	declare @strResult varchar(255)
 
	if @strIn is Null 
		begin
		        set @strIn = ''
		end
	
	if len(@strIn) < @intTotalLen
		begin
			-- pad right
			Set @strResult = left(@strIn + Replicate(@strPadChar,@intTotalLen),@intTotalLen) 
		end
	else 
		begin
			-- return the left @intTotalLen portion string
			Set @strResult = left(@strIn,@intTotalLen) 
		end

	return ( @strResult )
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ImpliedDecimalStringToDecimal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ImpliedDecimalStringToDecimal]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DateFromCCYYMMDD]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[DateFromCCYYMMDD]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



CREATE FUNCTION dbo.DateFromCCYYMMDD  (@strDate varchar(8))
RETURNS datetime
AS
BEGIN
Declare @dtResult datetime

--** If Day is missing, Set to 01
if len(@strDate)=6 
  Begin
	Set @strDate = @strDate + '01'
  End

if isDate(@strDate) = 1
  Begin
	Set @dtResult = Cast(@strDate as datetime) 
  End
Else
  Begin
	Set @dtResult = Null
  End
  RETURN(@dtResult)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION dbo.ImpliedDecimalStringToDecimal(@pNumber varchar(9))
RETURNS decimal(9,2)
AS
BEGIN
  Declare @Result decimal(9,2)
  Declare @Number decimal(9,2)

-- doesn't do nulls
    IF (@pNumber is Null )
    BEGIN
        Set @pNumber = '0'
    END
 -- doesn't do non-numeric strings
 IF (isnumeric(@pNumber) = 0)
    BEGIN
	Set @pNumber = '0'
    END


Set @Number = cast(@pNumber as decimal)
Set @Result = (@Number / 100)

  RETURN ( @Result )

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Implied4DecimalStringToDecimal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Implied4DecimalStringToDecimal]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION dbo.Implied4DecimalStringToDecimal(@pNumber varchar(9))
RETURNS decimal(9,4)
AS
BEGIN
  Declare @Result decimal(9,4)
  Declare @Number decimal(9,4)

-- doesn't do nulls
    IF (@pNumber is Null )
    BEGIN
        Set @pNumber = '0'
    END
 -- doesn't do non-numeric strings
 IF (isnumeric(@pNumber) = 0)
    BEGIN
	Set @pNumber = '0'
    END

Set @Number = cast(@pNumber as decimal(9,4))
Set @Result = (@Number / 10000)

  RETURN ( @Result )

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

ALTER VIEW dbo.v_INRGDB_D_VEH_INT_TRANS
AS

/*
tip: use the "@" to identify fields that need to be integrated, 
*/
SELECT       
[@InternetTranKey]    = IntTranKey            , -- VarChar(18) : Char(18)                                            
[@DeliveryKey]        = CountyOffice+DeliveryOption    , -- VarChar(6) : Char(4)+Char(1)                             
[@CountyOfficeKey]    = CountyOffice          , -- VarChar(4) : Char(4)                                              
[@DepartmentReject]      = DeptReject            , -- Decimal 5(2,0) : Char(2)                                       
[@EquipmentNumber]    = EquipNo            , -- VarChar(8) : Char(8)                                                 
[@FilingFee]       = dbo.ImpliedDecimalStringToDecimal(FileFee)            , -- Decimal 5(5,2) : Integer                                                
[@GWTFee]       = dbo.ImpliedDecimalStringToDecimal(GwtFee)          , -- Decimal 5(7,2) : Integer                                                      
[@Lessor]       = Lessor          , -- Decimal 5(2,0) : Char(2)                                                      
[@LegalOwnerAddressCnt]     = LoAddrCnt          , -- Decimal 5(2,0) : Char(2)                                       
[@LegalOwnerCity]    = LoCity          , -- VarChar(20) : VarChar(20)                                               
[@LONameCnt]       = NoLegName          , -- Decimal 5(2,0) : Char(2)                                                
[@LegalOwnerNameAddress1]   = LoNmAddr1          , -- VarChar(30) : VarChar(30)                                      
[@LegalOwnerNameAddress2]   = LoNmAddr2          , -- VarChar(30) : VarChar(30)                                      
[@LegalOwnerNameAddress3]   = LoNmAddr3          , -- VarChar(30) : VarChar(30)                                      
[@LegalOwnerNameAddress4]   = LoNmAddr4          , -- VarChar(30) : VarChar(30)                                      
[@LegalOwnerNameAddress5]   = LoNmAddr5          , -- VarChar(30) : VarChar(30)                                      
[@LegalOwnerNameAddress6]   = LoNmAddr6          , -- VarChar(30) : VarChar(30)                                      
[@LegalOwnerState]    = LoState            , -- VarChar(2) : Char(2)                                                 
[@LegalOwnerZip]         = LoZip              , -- VarChar(6) : Char(5)                                              
[@LegalResidenceCounty]     = LegalResCnty          , -- Decimal 5(2,0) : Char(2)   
[@AddressValidationFlag] = AddrVal,     -- varchar(2) 
[@Lessee]       = Lessee          , -- Decimal 5(2,0) : Char(2)                                                      
[@ExpirationDate]     = dbo.DateFromCCYYMMDD(ExpDateVh)          , -- Datetime(8) : Char(8)                                                
[@Plate]           = Plate              , -- VarChar(8) : Char(7)                                                    
[@LPGFee]       = dbo.ImpliedDecimalStringToDecimal(LpgFee)          , -- Decimal 5(6,2) : Integer                                                      
[@LPGHandlingFee]     = dbo.ImpliedDecimalStringToDecimal(LpgHndlgFee)           , -- Decimal 5(5,2) : Integer                                          
[@Make]            = Make               , -- VarChar(6) : Char(5)                                                    
[@Color]           = Color              , -- VarChar(6) : Char(6)                                                    
-- HEAT 37244 - NMVTIS - DJF - 03/31/05                                                                                
[@VINAModelCode]         = VinaModelCode            , -- VarChar(4) : VarChar(4)                                     
[@VINABodyType]       = VinaBodyType          , -- VarChar(2) : Char(2)                                              
[@VINAGrossVehWeightRating] = VinaGVWR           , -- VarChar(2) : Char(2)                                           
[@BrandCodes1]        = SUBSTRING( BrandCodes, 1 , 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes2]        = SUBSTRING( BrandCodes, 5 , 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes3]        = SUBSTRING( BrandCodes, 9 , 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes4]        = SUBSTRING( BrandCodes, 13, 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes5]        = SUBSTRING( BrandCodes, 17, 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes6]        = SUBSTRING( BrandCodes, 21, 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes7]        = SUBSTRING( BrandCodes, 25, 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes8]        = SUBSTRING( BrandCodes, 29, 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes9]        = SUBSTRING( BrandCodes, 33, 4 ) , -- VarChar(4) : VarChar(100)                                
[@BrandCodes10]            = SUBSTRING( BrandCodes, 37, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes11]            = SUBSTRING( BrandCodes, 41, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes12]            = SUBSTRING( BrandCodes, 45, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes13]            = SUBSTRING( BrandCodes, 49, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes14]            = SUBSTRING( BrandCodes, 53, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes15]            = SUBSTRING( BrandCodes, 57, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes16]            = SUBSTRING( BrandCodes, 61, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes17]            = SUBSTRING( BrandCodes, 65, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes18]            = SUBSTRING( BrandCodes, 69, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes19]            = SUBSTRING( BrandCodes, 73, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes20]            = SUBSTRING( BrandCodes, 77, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes21]            = SUBSTRING( BrandCodes, 81, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes22]            = SUBSTRING( BrandCodes, 85, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes23]            = SUBSTRING( BrandCodes, 89, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes24]            = SUBSTRING( BrandCodes, 93, 4 )  , -- VarChar(4) : VarChar(100)                          
[@BrandCodes25]            = SUBSTRING( BrandCodes, 97, 4 )  , -- VarChar(4) : VarChar(100)                          
                                                                                                                    
[@BrandJurisdictions1]      = SUBSTRING( BrandJuris, 1 , 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions2]      = SUBSTRING( BrandJuris, 3 , 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions3]      = SUBSTRING( BrandJuris, 5 , 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions4]      = SUBSTRING( BrandJuris, 7 , 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions5]      = SUBSTRING( BrandJuris, 9 , 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions6]      = SUBSTRING( BrandJuris, 11, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions7]      = SUBSTRING( BrandJuris, 13, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions8]      = SUBSTRING( BrandJuris, 15, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions9]      = SUBSTRING( BrandJuris, 17, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions10]     = SUBSTRING( BrandJuris, 19, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions11]     = SUBSTRING( BrandJuris, 21, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions12]     = SUBSTRING( BrandJuris, 23, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions13]     = SUBSTRING( BrandJuris, 25, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions14]     = SUBSTRING( BrandJuris, 27, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions15]     = SUBSTRING( BrandJuris, 29, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions16]     = SUBSTRING( BrandJuris, 31, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions17]     = SUBSTRING( BrandJuris, 33, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions18]     = SUBSTRING( BrandJuris, 35, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions19]     = SUBSTRING( BrandJuris, 37, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions20]     = SUBSTRING( BrandJuris, 39, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions21]     = SUBSTRING( BrandJuris, 41, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions22]     = SUBSTRING( BrandJuris, 43, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions23]     = SUBSTRING( BrandJuris, 45, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions24]     = SUBSTRING( BrandJuris, 47, 2 ) , -- VarChar(2) : VarChar(50)                           
[@BrandJurisdictions25]     = SUBSTRING( BrandJuris, 49, 2 ) , -- VarChar(2) : VarChar(50)                           
                                                                                                                    
[@BrandOrigins1]         = SUBSTRING( BrandOrigCodes, 1 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins2]         = SUBSTRING( BrandOrigCodes, 2 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins3]         = SUBSTRING( BrandOrigCodes, 3 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins4]         = SUBSTRING( BrandOrigCodes, 4 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins5]         = SUBSTRING( BrandOrigCodes, 5 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins6]         = SUBSTRING( BrandOrigCodes, 6 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins7]         = SUBSTRING( BrandOrigCodes, 7 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins8]         = SUBSTRING( BrandOrigCodes, 8 , 1 )   , -- Char(1) : VarChar(26)                           
[@BrandOrigins9]         = SUBSTRING( BrandOrigCodes, 9, 1 ) , -- Char(1) : VarChar(26)                              
[@BrandOrigins10]     = SUBSTRING( BrandOrigCodes, 10, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins11]     = SUBSTRING( BrandOrigCodes, 11, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins12]     = SUBSTRING( BrandOrigCodes, 12, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins13]     = SUBSTRING( BrandOrigCodes, 13, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins14]     = SUBSTRING( BrandOrigCodes, 14, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins15]     = SUBSTRING( BrandOrigCodes, 15, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins16]     = SUBSTRING( BrandOrigCodes, 16, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins17]     = SUBSTRING( BrandOrigCodes, 17, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins18]     = SUBSTRING( BrandOrigCodes, 18, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins19]     = SUBSTRING( BrandOrigCodes, 19, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins20]     = SUBSTRING( BrandOrigCodes, 20, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins21]     = SUBSTRING( BrandOrigCodes, 21, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins22]     = SUBSTRING( BrandOrigCodes, 22, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins23]     = SUBSTRING( BrandOrigCodes, 23, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins24]     = SUBSTRING( BrandOrigCodes, 24, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins25]     = SUBSTRING( BrandOrigCodes, 25, 1 )   , -- Char(1) : VarChar(26)                              
[@BrandOrigins26]     = SUBSTRING( BrandOrigCodes, 26, 1 )   , -- Char(1) : VarChar(26)                              

[@BrandDates1]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 1  , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates2]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 9  , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates3]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 17 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates4]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 25 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates5]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 33 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates6]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 41 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates7]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 49 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates8]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 57 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates9]        = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 65 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates10]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 73 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates11]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 81 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates12]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 89 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates13]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 97 , 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates14]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 105, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates15]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 113, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates16]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 121, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates17]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 129, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates18]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 137, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates19]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 145, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates20]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 153, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates21]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 161, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates22]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 169, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates23]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 177, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates24]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 185, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)                         
[@BrandDates25]       = dbo.PAD_RIGHT(LTRIM(SUBSTRING( BrandDates, 193, 8 )),8,'0')   , -- Decimal 5(8,0) : VarChar(200)  
                                                                                                                    
[@ModelYear]       = ModelYrVh          , -- Decimal 5(4,0) : Char(4)                                                
[@NumberSeats]        = NoSeats            , -- VarChar(2) : Char(2)                                                 
[@PriorPlate]         = PrevPlate          , -- VarChar(8) : Char(7)                                                 
[@PlateFlag]       = PltFlags           , -- Decimal 13(24,0) : Char(24)                                             
[@ParkingTicketSurcharge]   = dbo.ImpliedDecimalStringToDecimal(PktSur)          , -- Decimal 5(5,2) : Integer                                          
[@PermPlateRenewalFee]      = dbo.ImpliedDecimalStringToDecimal(PermPltRenew)          , -- Decimal 5(5,2) : Integer                                    
[@PlateIssueDate]     = PltIssueDate          , -- Decimal 5(6,0) : Char(6)                                          
[@Power]           = Power              , -- VarChar(2) : Char(2)                                                    
[@ValueCode]       = ValueCodeVh           , -- Decimal 5(6,0) : Char(6)                                             
[@ValueYear]       = ValueYearVh           , -- Decimal 5(4,0) : Char(4)                                             
[@RegOwnerAddressCnt]    = RoAddrCnt          , -- Decimal 5(2,0) : Char(2)                                          
[@RegOwnerCity]       = RoCity          , -- VarChar(20) : VarChar(20)                                               
[@RONameCnt]       = NoRegName          , -- Decimal 5(2,0) : Char(2)                                                
[@RegOwnerNameAddress1]     = RoNmAddr1          , -- VarChar(30) : VarChar(30)                                      
[@RegOwnerNameAddress2]     = RoNmAddr2          , -- VarChar(30) : VarChar(30)                                      
[@RegOwnerNameAddress3]     = RoNmAddr3          , -- VarChar(30) : VarChar(30)                                      
[@RegOwnerNameAddress4]     = RoNmAddr4          , -- VarChar(30) : VarChar(30)                                      
[@RegOwnerNameAddress5]     = RoNmAddr5          , -- VarChar(30) : VarChar(30)                                      
[@RegOwnerNameAddress6]     = RoNmAddr6          , -- VarChar(30) : VarChar(30)                                      
[@RegOwnerState]         = RoState            , -- VarChar(2) : Char(2)                                              
[@RegOwnerZip]        = RoZip              , -- VarChar(6) : Char(5)       
[@OptionMailAddress1] = ROOptMailAddr1, 
[@OptionMailAddress2] = ROOptMailAddr2, 
[@OptionMailCity] = ROOptMailCity, 
[@OptionMailState] = ROOptMailState, 
[@OptionMailZip] = ROOptMailZip, 
[@OptionMailPlus4] = ROOptMailZip4, 
[@ScaleWeight]        = ScaleWt            , -- Decimal 5(6,0) : Char(6)                                             
[@SeriesBody]         = SerBody            , -- Char(8) : Char(8)                                                    
[@SubagentFee]        = dbo.ImpliedDecimalStringToDecimal(SubagentFee)           , -- Decimal 5(6,2) : Integer                                          
[@Tab]          = TabVh              , -- VarChar(8) : Char(8)                                                       
[@TabYear]         = TabYear            , -- VarChar(2) : Char(2)                                                    
[@LocalOptionTax]     = dbo.ImpliedDecimalStringToDecimal(LocalOptTax)           , -- Decimal 5(9,2) : Integer                                          
[@AquaticWeedFee]         = dbo.ImpliedDecimalStringToDecimal(AquaWdFee)          , -- Decimal 5(5,2) : Integer                                          
[@TotalFee]        = dbo.ImpliedDecimalStringToDecimal(TotalFee)        , -- Decimal 5(8,2) : Integer                                       
[@Use]          = UseVh              , -- VarChar(4) : Char(3)                                                       
[@VINFlags]        = VinFlags           , -- Decimal 13(24,0) : Char(24)                                             
[@VIN]          = VIN             , -- VarChar(18) : Char(17)                                                        
[@GWTExpirationDate]     = dbo.DateFromCCYYMMDD(ExpDateGwt)            , -- Datetime(8) : Char(8)                                          
[@GWT]          = Gwt             , -- Decimal 5(6,0) : Char(6)                                                      
[@GWTNumberMonths]    = NoMoGwt            , -- Decimal 5(2,0) : Char(2)                                             
[@RTAZone]         = RtaZoneCode           , -- VarChar(2) : Char(2)      
[@RTAStatus] = RtaStatus,                                           
[@RTATax]       = dbo.ImpliedDecimalStringToDecimal(RtaTax)          , -- Decimal 5(8,2) : Integer                                                      
[@SPMAJurisdiction]      = SpmaJuris          , -- Decimal 5(4,0) : Char(4)   
[@SPMAStatus] = SpmaStatus,                                       
[@SPMATax]         = dbo.ImpliedDecimalStringToDecimal(SpmaTax)            , -- Decimal 5(8,2) : Integer                                                
[@BilledDate]         = ''              , -- Datetime : ''                                                           
[@PushedToHQInd]         = '00'               , -- Decimal 5(2,0) : '00'                                             
[@TranStatus]         = 'P'             , -- VarChar(2) : 'P'                                                        
[@StatusDate]         = GetDate()                      , -- Datetime : DateTime                                      
[@StatusTime]         = Dbo.DateToHHMMSS( GetDate() )     , -- Decimal 5(6,0) : DateTime                             
[@InternetTranType]      = TranType           , -- VarChar(4) : Char(4)                                              
[@FinalOperator]         = 0              , -- Decimal 5(2,0) : ''                                                  
[@FinalWorkstation]      = 0              , -- Decimal 5(2,0) : ''                                                  
[@BasicFee]        = dbo.ImpliedDecimalStringToDecimal(BasicFee)           , -- Decimal 5(5,2) : Integer                                                
[@BasicBaseAmt]       = dbo.ImpliedDecimalStringToDecimal(BasicBasAmt)           , -- Decimal 5(5,2) : Integer                                          
[@CommercialSafetyFee]      = dbo.ImpliedDecimalStringToDecimal(ComSafFee)          , -- Decimal 5(8,2) : Integer                                       
[@SpecialPlateCode]      = SpecPlate          , -- VarChar(4) : Char(4)                                              
[@RenewalRemitGroup]     = 0              , -- Decimal 5(2,0) : ''                                                  
[@OnlineUpdateInd]    = 0              , -- Decimal 5(2,0) : ''                                                     
[@AdditionalNameFlag]    = AddNameFlag           , -- VarChar(2) : Char(2)                                           
[@SafetyDefectCorrected]    = SafeCorFlg            , -- Decimal 5(2,0) : Char(2)                                    
[@NonconformityUncorrectedFlag]   = NonconUncorFlg        , -- Decimal 5(2,0) : Char(2)                              
[@PrintSequenceNumber]      = 0              , -- Decimal 5(4,0) : ''                                               
[@Remark1]         = ''              , -- VarChar(80) : ''                                                           
[@Remark2]         = ''              , -- VarChar(80) : ''                                                           
[@Remark3]         = ''              , -- VarChar(80) : ''                                                           
[@MerchantID]         = MerchantID            , -- VarChar(30) : Char(10)                                            
[@MerchantReferenceCode]    = MerchIDRefCode        , -- VarChar(50) : VarChar(50)                                   
[@AuthorizationRequestId]   = AuthRequestID            , -- VarChar(254) : VarChar(255)                              
[@TranAmount]         = dbo.ImpliedDecimalStringToDecimal(TotalFee)        , -- Decimal 5(8,2)) : Integer                                      
[@CCType]       = CreditCardType        , -- VarChar(6) : Char(4)                                                    
[@CCLast5]         = CreditCardLast5       , -- Decimal 5(6,0) : Char(5)                                             
[@AuthorizationTranDate]    = dbo.DateFromCCYYMMDD(CCAuthDateTime)                 , -- Datetime : DateTime                                
[@AuthorizationTranTime]    = Dbo.DateToHHMMSS( CCAuthDateTime )   , -- Decimal 5(6,0) : DateTime                    
[@CCName]       = CCName          , -- VarChar(60) : VarChar(60)                                                     
[@LicenseServiceFee]     = dbo.ImpliedDecimalStringToDecimal(LicServFee)            , -- Decimal 5(5,2) : Integer                                       
[@RecVehicleDisposalFee]    = dbo.ImpliedDecimalStringToDecimal(RvDisposalFee)            , -- Decimal 5(5,2) : Integer                                 
[@ReplacePlate]       = CASE               WHEN ReplacePlate =1 THEN 'Y'                                             
      ELSE 'N'                                                                                                      
      END                     , --VarChar(2) : Integer                                                              
[@ReplaceWithSame]    = cast(coalesce(ReplaceWithSame, 0) as char(1)), --VarChar(2) : Integer                        
[@IssuePlateFee]      = dbo.ImpliedDecimalStringToDecimal(IssuePltFee)           , -- Decimal 5(8,2) : Integer                                          
[@ReflectiveFee]         = dbo.ImpliedDecimalStringToDecimal(RegReflectFee)            , -- Decimal 5(5,2) : Integer                                    
[@PermPlateReflectiveFee]   = dbo.ImpliedDecimalStringToDecimal(PermReflect)           , -- Decimal 5(5,2) : Integer                                    
[@CentennialFee]         = dbo.ImpliedDecimalStringToDecimal(CentFee)            , -- Decimal 5(5,2) : Integer                                          
[@OrganDonorFee]         = dbo.ImpliedDecimalStringToDecimal(OrganDonorFee)            , -- Decimal 5(6,2) : Integer                                    
[@RegMenuOption]         = RegMenuOpt            , -- VarChar(26) : VarChar(26)                                      
[@Pattern]         = PlatePattern,           -- VarChar(8) : VarChar(7)     
---------------------------------------------------------------------------                                         
-- Fields on SQL Server, not on HP Database...                                                                      
---------------------------------------------------------------------------                                         
[_PushedToRegion] = PushedToRegion, -- indicator that the record was pushed
[_DeliveryOption] = DeliveryOption -- not sure why we sort on this but its not used by the receiving database

From tblVehTransactions                                                                                             

GO

/*
     Name: usp_HpInt_Veh_GetRecs
	   HP3000 Integration Vehicle Get Records.
  Purpose: Return Vehicle Records that Need To Be Pushed.
    Input: None
   Output: Recordset.
*/
ALTER PROCEDURE dbo.usp_HpInt_Veh_GetRecs
AS
BEGIN

	SET NOCOUNT ON

	SELECT * 
	FROM dbo.v_INRGDB_D_VEH_INT_TRANS
	WHERE _PushedToRegion = 0 
	ORDER BY _DeliveryOption DESC

END
GO


/*
*    Name: usp_HpInt_Veh_Pushed
	   HP3000 Integration Vehicle Pushed 
  Purpose: Update tblVehTransactions.PushedToRegion to 1.
           This indicates that it was Pushed To Regional Processor
    Input: IntTranKey (Internet Transaction Key) 
   Output: None
   Return: Return Value contains @@ROWCOUNT (Number of records changed).
	   Zero indicates failure.  
  
*/
ALTER PROCEDURE dbo.usp_HpInt_Veh_Pushed
@pstrInput	   varchar(2000)	, --* IntTranKey (Unique).
@pdatStartTime datetime -- interface stat start time
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @PushedCount  int

	-- Here is the main goal of what we are trying to do...   Update the PushedToRegion Flag.	
	UPDATE tblVehTransactions 
	SET PushedToRegion = 1
	WHERE IntTranKey = @pstrInput
	AND PushedToRegion = 0
	
	-- Store the Answer...
	Set  @PushedCount = @@ROWCOUNT

	IF @PushedCount = 1
	BEGIN
		-- Record Successfully marked up as pushed...   
		-- Add Statistics Record.
		INSERT tblInterfaceStats 
		(InterfaceType, StartTime, EndTime,Processor)
		values
		('VINT', @pdatStartTime, GetDate(), 'DOL1')
	END
	
	-- Return a Single Record containing STATUS of this Transaction...
	SELECT Status = 
		Case @PushedCount
			When 1 Then 'SUCCESS'
			Else 'ERROR' 
		END
END
GO



/*
     Name: usp_HpInt_Ves_GetRecs
	   HP3000 Integration Vessel Get Records.
  Purpose: Return Vessel Records that Need To Be Pushed.
    Input: None
   Output: Recordset.
*/
ALTER PROCEDURE dbo.usp_HpInt_Ves_GetRecs
AS
BEGIN

	SET NOCOUNT ON

	SELECT * 
	FROM  dbo.v_INRGDB_D_VES_INT_TRANS
	WHERE _PushedToRegion = 0 
	ORDER BY _DeliveryOption DESC

END
GO

ALTER View dbo.v_INRGDB_D_VES_INT_TRANS
AS
/*
tip: use the "@" to identify fields that need to be integrated, 
*/
 SELECT                 
[@InternetTranKey]          = IntTranKey                   , -- VarChar(18) : Char(18)               
[@DeliveryKey]              = CountyOffice+DeliveryOption  , -- VarChar(6) : Char(4)+Char(1)         
[@CountyOfficeKey]          = CountyOffice                 , -- VarChar(4) : Char(4)                 
[@RegNumber]                = RegNo                        , -- VarChar(6) : Char(6)                 
[@LegalResidenceCounty]        = LegalResCnty                 , -- Decimal 5(2,0) : Char(2)          
[@FinalWorkstation]            = 0                         , -- Decimal 5(2,0) : '00'             
[@FinalOperator]               = 0                         , -- Decimal 5(2,0) : '00'             
[@VesselRegOwnerAddressStatus]    = VsRoAddrStat                 , -- VarChar(2) : Char(2)           
[@TotalFee]                 = dbo.ImpliedDecimalStringToDecimal(TotalFee)         , -- Decimal 5(8,2) : Char(8)             
[@ModelYear]                = ModelYrVs                    , -- Decimal 5(4,0) : Char(4)             
[@VesselMake]               = MakeVs                       , -- VarChar(8) : Char(8)                 
[@HIN]                      = HIN                          , -- VarChar(20) : Char(20)               
[@PurchaseCost]             = dbo.ImpliedDecimalStringToDecimal(PurchCost)                    , -- Decimal 9(10,2) : Char(10)           
[@PurchaseYear]                = PurchYr                      , -- Decimal 5(4,0) : Char(4)          
[@RegNumberMonths]             = NoMoReg                      , -- Decimal 5(2,0) : Char(2)          
[@ExpirationDate]           = dbo.DateFromCCYYMMDD(ExpDateVs)                    , -- Datetime(8) : Char(8)                
[@SeriesBodyVessel]            = SerBodyVs                    , -- VarChar(8) : Char(8)              
[@PriorRegNo]               = PrevRegNo                    , -- VarChar(6) : Char(6)                 
[@Comment]                  = Comment                      , -- VarChar(20) : VarChar(20)            
[@GroupCode]                = 0                           , -- Decimal 5(4,0) : ''                  
[@RecordType]               = ''                           , -- VarChar(2) : ''                      
[@MoorageCounty]               = CntyMoor                     , -- Decimal 5(2,0) : Char(2)          
[@DocumentNumber]           = DocumentNo                   , -- Decimal 5(8,0) : Char(8)             
[@VesselIndicators]         = VsIndicators                 , -- VarChar(6) : Char(6)                 
[@VesselFlagCnt]            = VsFlagCnt                    , -- Decimal 5(2,0) : Char(2)             
[@RONameCnt]                = NoRegName                    , -- Decimal 5(2,0) : Char(2)             
[@LegalOwnerAddressCnt]           = LoAddrCnt                    , -- Decimal 5(2,0) : Char(2)       
[@LienCode]                 = LienCode                     , -- VarChar(4) : Char(4)                 
[@VesselRegOwnerCity]             = RoCityVs                     , -- VarChar(24) : VarChar(24)      
[@RegOwnerState]               = RoState                      , -- VarChar(2) : Char(2)              
[@VesselRegOwnerZip]              = RoZipVs                      , -- VarChar(10) : Char(10)         
[@VesselLegalOwnerCity]           = LoCityVs                     , -- VarChar(24) : VarChar(24)      
[@LegalOwnerState]                = LoState                      , -- VarChar(2) : Char(2)           
[@VesselLegalOwnerZip]            = LoZipVs                      , -- VarChar(10) : Char(10)         
[@RegOwnerName1]               = RoName1                      , -- VarChar(30) : VarChar(30)         
[@RegOwnerName2]               = RoName2                      , -- VarChar(30) : VarChar(30)         
[@RegOwnerAddress1]           = RoAddr1                      , -- VarChar(30) : VarChar(30)      
[@RegOwnerAddress2]           = RoAddr2                      , -- VarChar(30) : VarChar(30)      
[@RegOwnerAddress3]           = RoAddr3                      , -- VarChar(30) : VarChar(30)      
[@RegOwnerAddress4]           = RoAddr4                      , -- VarChar(30) : VarChar(30)      
[@RegOwnerPICUBI1]       = VsRoPicUBIAr1                , -- VarChar(16) : Char(16)                  
[@RegOwnerPICUBI2]       = VsRoPicUBIAr2                , -- VarChar(16) : Char(16)                  
[@LegalOwnerName1]                = LoName1                      , -- VarChar(30) : VarChar(30)      
[@LegalOwnerName2]                = LoName2                      , -- VarChar(30) : VarChar(30)      
[@LegalOwnerAddress1]         = LoAddr1                      , -- VarChar(30) : VarChar(30)      
[@LegalOwnerAddress2]         = LoAddr2                      , -- VarChar(30) : VarChar(30)      
[@LegalOwnerAddress3]         = LoAddr3                      , -- VarChar(30) : VarChar(30)      
[@LegalOwnerAddress4]         = LoAddr4                      , -- VarChar(30) : VarChar(30)      
[@LegalOwnerPICUBI1]        = VsLoPicUBIAr1                , -- VarChar(16) : Char(16)               
[@LegalOwnerPICUBI2]        = VsLoPicUBIAr2                , -- VarChar(16) : Char(16)               
[@VesselCancelDHCFlag]         = Flg01CancDHC                 , -- Decimal 5(2,0) : Char(2)          
[@VesselCancelRefundedFlag]        = Flg02CancRfd                 , -- Decimal 5(2,0) : Char(2)          
[@VesselSuspendedRegistrationFlag]    = Flg03SuspReg                 , -- Decimal 5(2,0) : Char(2)   
[@VesselReportOfSaleFlag]         = Flg05RptSale                 , -- Decimal 5(2,0) : Char(2)       
[@VesselCallOlympiaFlag]       = Flg09CallOly                 , -- Decimal 5(2,0) : Char(2)          
[@VesselNonResidentMilitary]      = Flg10NRM                     , -- Decimal 5(2,0) : Char(2)       
[@VesselNativeAmericanFlag]       = Flg11NatAmer                 , -- Decimal 5(2,0) : Char(2)       
[@VesselCommercialFishingFlag]    = Flg12CommFish                , -- Decimal 5(2,0) : Char(2)       
[@VesselGovernmentAgencyFlag]     = Flg13Govern                  , -- Decimal 5(2,0) : Char(2)       
[@VesselNonProfitOrganizationFlag]   = Flg14NonPro                  , -- Decimal 5(2,0) : Char(2)    
[@VesselNatAmerAndCommFishFlag]      = Flg15NatComm                 , -- Decimal 5(2,0) : Char(2)    
[@VesselReturnedUnclaimedFlag]    = Flg17RtnUncl                 , -- Decimal 5(2,0) : Char(2)       
[@VesselExciseExemptFlag]         = Flg18ExcXmpt                 , -- Decimal 5(2,0) : Char(2)       
[@VesselNoServiceRenderedFlag]       = Flg20NoServ                  , -- Decimal 5(2,0) : Char(2)    
[@VesselLegalOwnerFlag]        = Flg21LegOwner                , -- Decimal 5(2,0) : Char(2)          
[@VesselLeasedFlag]         = Flg22Leasee                  , -- Decimal 5(2,0) : Char(2)             
[@VesselForeignTitleFlag]         = Flg23FrgnTtl                 , -- Decimal 5(2,0) : Char(2)       
[@VesselLieuBondFlag]       = Flg24LieuBnd                 , -- Decimal 5(2,0) : Char(2)             
[@VesselTitlePendingFlag]         = Flg25TtlPend                 , -- Decimal 5(2,0) : Char(2)       
[@VesselTitleRejectFlag]          = Flg27Reject                  , -- Decimal 5(2,0) : Char(2)       
[@VesselJointTenantsFlag]      = Flg28JTWROS                  , -- Decimal 5(2,0) : Char(2)          
[@VesselDoubleTransferFlag]       = Flg29DblTfr                  , -- Decimal 5(2,0) : Char(2)       
[@VesselReportOfSaleWithDocumentsFlag] = Flg30RsWDoc                 , -- Decimal 5(2,0) : Char(2)   
[@VesselDepartmentHoldFlag]    = Flg33DeptHld                 , -- Decimal 5(2,0) : Char(2)          
[@VesselDHCFlag]            = Flg34DHC                     , -- Decimal 5(2,0) : Char(2)             
[@VesselStolenFlag]         = Flg35Stolen                  , -- Decimal 5(2,0) : Char(2)             
[@VesselBondedFlag]         = Flg36Bonded                  , -- Decimal 5(2,0) : Char(2)             
[@VesselDualRegisteredFlag]    = Flg37DualReg                 , -- Decimal 5(2,0) : Char(2)          
[@VesselAdditionalOwnerFlag]      = Flg38AddOwnr                 , -- Decimal 5(2,0) : Char(2)       
[@VesselDestroyedFlag]         = Flg40DstrVes                 , -- Decimal 5(2,0) : Char(2)          
[@VesselTitledOutOfStateFlag]     = Flg42VsOutst                 , -- Decimal 5(2,0) : Char(2)       
[@VesselOwnershipInDoubtFlag]     = Flg50OwnrDbt                 , -- Decimal 5(2,0) : Char(2)       
[@VesselTitledAsVehicleFlag]      = Flg51TtlAsvh                 , -- Decimal 5(2,0) : Char(2)       
[@VesselGiftFlag]           = Flg56Gift                    , -- Decimal 5(2,0) : Char(2)             
[@VesselOverageFlag]           = Flg62Over                    , -- Decimal 5(2,0) : Char(2)          
[@VesselShortageFlag]          = Flg63Short                   , -- Decimal 5(2,0) : Char(2)          
[@VesselDocumentedBoatFlag]    = Flg99DocBoat                 , -- Decimal 5(2,0) : Char(2)          
[@DecalYear]                = DecalYr                      , -- Decimal 5(2,0) : Char(2)             
[@DecalNumber]              = DecalNo                      , -- VarChar(8) : Char(8)                 
[@FilingFee]                = dbo.ImpliedDecimalStringToDecimal(FileFee)                      , -- Decimal 5(5,2) : SmallInt            
[@ExciseTax]                = dbo.ImpliedDecimalStringToDecimal(ExciseTx)                     , -- Decimal 5(9,2) : Integer             
[@BasicFee]                 = dbo.ImpliedDecimalStringToDecimal(BasicFee)                     , -- Decimal 5(5,2) : SmallInt            
[@ApplicationFee]              = dbo.ImpliedDecimalStringToDecimal(ApplicFee)                    , -- Decimal 5(5,2) : SmallInt         
[@InspectionFee]            = dbo.ImpliedDecimalStringToDecimal(InspectFee)                   , -- Decimal 5(5,2) : SmallInt            
[@ReplaceRegFee]            = dbo.ImpliedDecimalStringToDecimal(RepRegFee)                    , -- Decimal 5(5,2) : SmallInt            
[@DuplicateRegFee]             = dbo.ImpliedDecimalStringToDecimal(DupRegFee)                    , -- Decimal 5(5,2) : SmallInt         
[@DuplicateTitleFee]             = dbo.ImpliedDecimalStringToDecimal(DupTtlFee)                    , -- Decimal 5(5,2) : SmallInt         
[@RTAUseTax]             = dbo.ImpliedDecimalStringToDecimal(RtaUseTax)                    , -- Decimal 5(8,2) : Integer          
[@RTAUseTaxDue]             = dbo.ImpliedDecimalStringToDecimal(RtaUseDue)                    , -- Decimal 5(8,2) : Integer             
[@CountyUseTax]             = dbo.ImpliedDecimalStringToDecimal(CountyUseTax)                 , -- Decimal 5(8,2) : Integer             
[@LocalUseTax]              = dbo.ImpliedDecimalStringToDecimal(LocalUseTax)                  , -- Decimal 5(8,2) : Integer             
[@StateUseTax]              = dbo.ImpliedDecimalStringToDecimal(StateUseTax)                  , -- Decimal 5(8,2) : Integer             
[@ReplaceTabFee]            = dbo.ImpliedDecimalStringToDecimal(RepTabFee)                    , -- Decimal 5(5,2) : SmallInt            
[@PriorShortageAmount]         = dbo.ImpliedDecimalStringToDecimal(PriorShortAmt)                , -- Decimal 5(8,2) : Integer          
[@OtherFees]                = dbo.ImpliedDecimalStringToDecimal(OtherFees)                    , -- Decimal 5(8,2) : Integer             
[@SubagentFee]              = dbo.ImpliedDecimalStringToDecimal(SubagentFee)                  , -- Decimal 5(6,2) : SmallInt            
[@PublicDisclosureFee]            = dbo.ImpliedDecimalStringToDecimal(PubDisFee)                    , -- Decimal 5(5,2) : SmallInt      
[@TransferFee]              = dbo.ImpliedDecimalStringToDecimal(TransferFee)                  , -- Decimal 5(5,2) : SmallInt            
[@DealerTempFee]            = dbo.ImpliedDecimalStringToDecimal(DlrTempFee)                   , -- Decimal 5(5,2) : SmallInt            
[@HistoricalVesselFee]            = dbo.ImpliedDecimalStringToDecimal(HistVesFee)                   , -- Decimal 5(9,2) : Integer       
[@LicenseServiceFee]           = dbo.ImpliedDecimalStringToDecimal(LicServFee)                   , -- Decimal 5(5,2) : SmallInt         
[@VesselInventoryFlag]            = SwInventory                  , -- VarChar(2) : Char(2)           
[@DocBoatFlag]              = DocBoatFlag                  , -- VarChar(2) : Char(2)                 
[@OutputCode]               = OutputCode                   , -- VarChar(2) : Char(2)                 
[@PrintSequenceNumber]            = 0                           , -- Decimal 5(4,0) : ''            
[@ForeignRegNumber]            = ForeignReg                   , -- VarChar(8) : Char(8)              
[@TaxJurisdiction]             = TaxJuris                     , -- SmallInt : SmallInt               
[@TaxRate]                  = dbo.Implied4DecimalStringToDecimal(TaxRate)                      , -- Decimal 5(5,4) : SmallInt            
[@LocalOptionTax]           = dbo.ImpliedDecimalStringToDecimal(LocalOptTax)                  , -- Decimal 5(9,2) : Integer             
[@RemarkArrayVessel1]       = RemarkArryVs1                , -- VarChar(60) : VarChar(60)            
[@RemarkArrayVessel2]       = RemarkArryVs2                , -- VarChar(60) : VarChar(60)            
[@DepartmentReject]            = DeptReject                   , -- Decimal 5(2,0) : Char(2)          
[@Lessee]                   = Lessee                       , -- Decimal 5(2,0) : Char(2)             
[@BilledDate]               = null                           , -- Datetime(8) : ''                     
[@PushedToHQInd]         = 0                         , -- Decimal 5(2,0) : '00'                   
[@InternetTranType]         = IntTranType                  , -- VarChar(4) : Char(4)                 
[@OnlineUpdateInd]          = 0                         , -- Decimal 5(2,0) : '00'                
[@TranStatus]               = 'P'                          , -- VarChar(2) : 'P'                     
[@StatusDate]               = GetDate()                    , -- Datetime : DateTime                  
[@StatusTime]               = Dbo.DateToHHMMSS( GetDate() ), -- Decimal 5(6,0) : DateTime            
[@MerchantID]               = MerchantID                   , -- VarChar(30) : Char(10)               
[@MerchantReferenceCode]          = MerchIDRefCode               , -- VarChar(50) : VarChar(50)      
[@AuthorizationRequestId]         = AuthRequestID                , -- VarChar(254) : VarChar(254)    
[@TranAmount]               = dbo.ImpliedDecimalStringToDecimal(TotalFee)         , -- Decimal 5(8,2) : Char(8)                
[@CCType]             = CreditCardType               , -- VarChar(6) : Char(4)                       
[@CCLast5]            = CreditCardLast5              , -- Decimal 5(6,0) : Char(5)                   
[@AuthorizationTranDate]       = CCAuthDateTime               , -- Datetime : DateTime               
[@AuthorizationTranTime]       = Dbo.DateToHHMMSS( CCAuthDateTime ), -- Decimal 5(6,0) : DateTime    
[@CCName]                   = CCName                       , -- VarChar(60) : VarChar(60)    
[@DerelictFee]		    = 0.00,        

/*Fields on SQL Server, not on HP Database... */
 [_DeliveryOption]            = DeliveryOption               , --  : Char(1)                        
 [_PushedToRegion]            = PushedToRegion                 --  : TinyInt                        

From tblVesTransactions 


GO
/*
*    Name: usp_HpInt_Ves_Pushed
	   HP3000 Integration Vessel Pushed 
  Purpose: Update v_INRGDB_D_VES_INT_TRANS.PushedToRegion to 1.
           This indicates that it was Pushed To Regional Processor
    Input: IntTranKey (Internet Transaction Key) 
   Output: None
   Return: Return Value contains @@ROWCOUNT (Number of records changed).
	   Zero indicates failure.  
  
*/
ALTER PROCEDURE dbo.usp_HpInt_Ves_Pushed
@pstrInput	   varchar(2000),	--* IntTranKey (Unique).
@pdatStartTime datetime
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @PushedCount  int

	-- Here is the main goal of what we are trying to do...   Update the PushedToRegion Flag.	
	UPDATE v_INRGDB_D_VES_INT_TRANS 
	SET _PushedToRegion = 1
	WHERE [@InternetTranKey] = @pstrInput
	AND _PushedToRegion = 0
	
	-- Store the Answer...
	Set  @PushedCount = @@ROWCOUNT

	IF @PushedCount = 1
	BEGIN
		-- Record Successfully marked up as pushed...   
		-- Add Statistics Record.
		INSERT tblInterfaceStats 
		(InterfaceType, StartTime, EndTime,Processor)
		values
		('VINT', @pdatStartTime, GetDate(), 'DOL1')
	END
	
	-- Return a Single Record containing STATUS of this Transaction...
	SELECT Status = 
		Case @PushedCount
			When 1 Then 'SUCCESS'
			Else 'ERROR' 
		END
END
GO

-- DROP OLD STUFF
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_HPInt_CheckOutInit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_HPInt_CheckOutInit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_HPInt_Veh_Checkout]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_HPInt_Veh_Checkout]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_HPInt_Ves_Checkout]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_HPInt_Ves_Checkout]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_HpInt_CheckOutExit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_HpInt_CheckOutExit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_HpInt_ErrorLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_HpInt_ErrorLog]
GO

