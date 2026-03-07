ALTER Procedure [dbo].[fw_getFormGridUser]  
@UserID as int ,                      
@ObjectID as int ,                      
@GridName as nvarchar(50),                      
@lang as nvarchar(5)  
as                      
BEGIN          
Declare @iCount as int              
Select @iCount  = count(*) from fw_FormGrid                      
   inner join fw_FormGridUser on fw_FormGridUser.FormGridID = fw_FormGrid.id                      
   left outer join fw_LOVStatments on fw_LOVStatments.ID = fw_FormGrid.lovid                      
   Where UserID=@UserID AND fw_FormGrid.ObjectID=@ObjectID and GridName=@GridName              
         
if  @iCount = 0  and @UserID<>1              
  begin              
  insert into fw_FormGridUser(FormGridID,UserID,ColumnOrdinal,ColumnWidth,ColumnReadOnly,UpdateDateTime)              
  select fw_FormGridUser.FormGridID,@UserID,fw_FormGridUser.ColumnOrdinal,fw_FormGridUser.ColumnWidth,fw_FormGridUser.ColumnReadOnly,fw_FormGridUser.UpdateDateTime from fw_FormGrid              
   inner join fw_FormGridUser on fw_FormGridUser.FormGridID = fw_FormGrid.id                      
  Where UserID=1 AND fw_FormGrid.ObjectID=@ObjectID and GridName=@GridName              
  end              
  --          
if  @iCount = 0  and @UserID = 1          
  begin              
  insert into fw_FormGridUser(FormGridID,UserID,ColumnOrdinal,ColumnWidth,ColumnReadOnly,UpdateDateTime)              
  select fw_FormGrid.ID,@UserID,fw_FormGrid.ColumnOrdinal,fw_FormGrid.ColumnWidth,fw_FormGrid.ColumnReadOnly,fw_FormGrid.UpdateDateTime from fw_FormGrid              
  Where  fw_FormGrid.ObjectID=@ObjectID and GridName=@GridName              
  end              
         
Select fw_FormGridUser.id ,fw_FormGrid.ObjectID   ,ColumnName                    
 , fw_FormGrid.id ,fw_FormGrid.GridName  ,   
 case when @lang='_AR'    
then dbo.fw_FormGrid.ColumnName_Ar    
else dbo.fw_FormGrid.ColumnName_En    
end as ColumnCaption  
   
 , fw_FormGridUser.ColumnOrdinal ,ColumnColor ,fw_FormGridUser.ColumnWidth ,fw_FormGridUser.ColumnReadOnly,ColumnType                      
  , fw_FormGrid.lovid , SQLString   from fw_FormGrid                      
   inner join fw_FormGridUser on fw_FormGridUser.FormGridID = fw_FormGrid.id                      
   left outer join fw_LOVStatments on fw_LOVStatments.ID = fw_FormGrid.lovid                      
   Where UserID=@UserID AND fw_FormGrid.ObjectID=@ObjectID and GridName=@GridName    
   order by fw_FormGridUser.ColumnOrdinal  
  
  
END    