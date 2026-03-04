
go

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetUserPasswordHash_desktop')
    DROP PROCEDURE [dbo].[GetUserPasswordHash_desktop]
GO
CREATE PROCEDURE GetUserPasswordHash_desktop  
@CompanyName nvarchar(50)        
,@USERNAME nvarchar(50)        
AS        
        
select Password as PasswordHash , fw_Users.ID as KeyUserID, fw_Users.ID as UserID,  fw_Users.USERNAME  
from fw_Users         
WHERE USERNAME = @USERNAME        
and Status= 1      



go

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_GetUserDashboardData')
    DROP PROCEDURE [dbo].[usp_GetUserDashboardData]
GO
CREATE PROCEDURE usp_GetUserDashboardData    
    @UserId    NVARCHAR(50),    
    @BranchID  INT,    
    @ModuleID  INT,    
@lang as nvarchar(5)      
AS    
BEGIN    
    SET NOCOUNT ON;    
    
    SELECT    
case when @lang='_AR'      
then U.UserFullName_Ar      
else U.UserFullName_EN      
end as UserFullName  ,    
        U.canSelectBranchInReport,    
        U.FilterByUserID,    
        U.add2,    
        U.module AS Module,    
       '' as TaxCard , --B.TaxCard,    
case when @lang='_AR'      
then B.Name_Ar      
else B.Name_En    
end as BranchName  ,    
    
(Select count(1) from  fw_UserGroups    
Where GroupID= 100 and UserId= U.ID ) as IsAdmin,    
    
(Select count(1) from  fw_GroupModule    
inner join fw_UserGroups    
on fw_UserGroups.GroupID = fw_GroupModule.GroupID    
Where ModuleID =U.module and UserId= U.ID)  as HasPermission    
     
    FROM fw_Users U    
    LEFT JOIN fw_Branches B ON B.ID = @BranchID    
    WHERE U.ID = @UserId AND U.Status = 1;    
END; 



GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_fw_LoadAllControls')
    DROP PROCEDURE [dbo].[sp_fw_LoadAllControls]
GO
CREATE Proc [dbo].[sp_fw_LoadAllControls] (@UserID int,    
@lang as nvarchar(5)      
)        
as        
begin        
       
SELECT ObjectID ,CtrlName, CtrlType,     
case when @lang='_AR'        
then CtrlCaption_AR     
else CtrlCaption_EN    
end as CtrlCaption      
    
       ,fw_UserControls.CtrlID, fw_UserControls.CtrlEnable_Browse, fw_UserControls.CtrlVisible_Browse,        
       fw_UserControls.CtrlEnable_Add, fw_UserControls.CtrlVisible_Add, fw_UserControls.CtrlEnable_Edit, fw_UserControls.CtrlVisible_Edit,        
       fw_UserControls.CtrlFontName, fw_UserControls.CtrlFontSize, fw_UserControls.CtrlFontBold, isnull(CtrlMandatory ,0) as CtrlMandatory        
FROM fw_UserControls WITH (NOLOCK)        
INNER JOIN fw_Controls WITH (NOLOCK) ON fw_Controls.ID = fw_UserControls.CtrlID        
WHERE UserID = @UserID        
ORDER BY fw_Controls.ID        
       
end


GO


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_fw_LoadAllfw_ObjectReports')
    DROP PROCEDURE [dbo].[sp_fw_LoadAllfw_ObjectReports]
GO
CREATE Proc [dbo].[sp_fw_LoadAllfw_ObjectReports] (@Module int)     as     begin     select fw_ObjectReports.* from fw_ObjectReports   
inner join fw_Objects on fw_Objects .ID= ObjectID    where  fw_Objects.ObjectModule=@Module        end


GO


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_fw_GetUserMenuData')
    DROP PROCEDURE [dbo].[sp_fw_GetUserMenuData]
GO
CREATE Proc [dbo].[sp_fw_GetUserMenuData] (@BranchID int,@UserID int,@module Int,    
    @Lang NVARCHAR(5) = null    
)        
as        
begin        
if @Lang is null begin set @Lang='_AR' end     
 SELECT  DISTINCT  dbo.fw_Objects.TableOrderBy , dbo.fw_Objects.ID AS ObjectID,         
 dbo.fw_Objects.ObjectLOV, dbo.fw_Objects.ObjectFullName,  dbo.fw_Objects.ObjectCaption_Ar,         
 dbo.fw_Objects.ObjectCaption_En,     
     
  CASE       
            WHEN @Lang = '_AR' THEN fw_Objects.ObjectCaption_AR    
            ELSE fw_Objects.ObjectCaption_EN      
        END AS ObjectName,      
    
    
    
    
   dbo.fw_Objects.ObjectParentID, cast (dbo.fw_Objects.ObjectType as int )as ObjectType         
   , ISNULL(dbo.fw_Objects.Parameters, '') AS Parameters, dbo.fw_Objects.ReportSql,         
           
   dbo.fw_Objects.Popup , fw_Objects.AddAlignString , dbo.fw_UserGroups.UserID, cast         
   (dbo.fw_Objects.RibbonStyle as int )as RibbonStyle  ,          
     fw_Objects.HasBranch ,fw_Objects.HasAttachment ,fw_Objects.HasUser ,          
       fw_Objects.HasCustomUserValidation ,fw_Objects.HasPrint ,fw_Objects.NewAfterAdd ,          
         fw_Objects.AskBeforeExist ,fw_Objects.ReportFile ,        
                 
         fw_Objects.DetailsProcedure  FROM         dbo.fw_Objects          
         FULL OUTER JOIN dbo.fw_GroupObjects ON         
         dbo.fw_Objects.ID = dbo.fw_GroupObjects.ObjectID         
          FULL OUTER JOIN dbo.fw_UserGroups ON         
          dbo.fw_GroupObjects.GroupID = dbo.fw_UserGroups.GroupID         
           WHERE (dbo.fw_Objects.ObjectEnabled = 1)  AND (dbo.fw_Objects.ObjectModule = @module)  AND fw_UserGroups.BranchID =@BranchID  AND (dbo.fw_UserGroups.UserID = @UserID)        
             OR(fw_Objects.ObjectType=0)        
             -- to include the <100 ORDER BY dbo.fw_Objects.TableOrderBy         
              end


GO