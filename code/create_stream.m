function create_stream(fname,longxy,latixy,date_tag,time,varnames,vars)
    ncid = netcdf.create(fname,'NC_CLOBBER');
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%                           Define dimensions
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    [nlon,nt] = size(vars{1});
    dimid(1) = netcdf.defDim(ncid,'lon', nlon);
    dimid(2) = netcdf.defDim(ncid,'lat', 1);
    dimid(3) = netcdf.defDim(ncid,'time',nt);
    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%                           Define variables
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ivar = 1;
varid(1) = netcdf.defVar(ncid,'time','NC_FLOAT',[dimid(3)]); 
netcdf.putAtt(ncid,ivar-1,'calendar','noleap');
netcdf.putAtt(ncid,ivar-1,'units',['days since ' date_tag]);

ivar = 2;
varid(2) = netcdf.defVar(ncid,'lon','NC_FLOAT',[dimid(1) dimid(2)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','longitude');
netcdf.putAtt(ncid,ivar-1,'units','degrees_east');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

ivar = 3;
varid(3) = netcdf.defVar(ncid,'lat','NC_FLOAT',[dimid(1) dimid(2)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','latitude');
netcdf.putAtt(ncid,ivar-1,'units','degrees_north');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');


for i = 1 : length(varnames)
    switch varnames{i}
        case 'T'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(1) dimid(2) dimid(3)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','Sea temperature');
            netcdf.putAtt(ncid,ivar+i-1,'units','K');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'Inund'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(1) dimid(2) dimid(3)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','Coastal inundation');
            netcdf.putAtt(ncid,ivar+i-1,'units','[-]');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'SSH'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(1) dimid(2) dimid(3)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','Sea surface height');
            netcdf.putAtt(ncid,ivar+i-1,'units','[m]');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        otherwise
            error('No such variable');
    end
end
varid = netcdf.getConstant('GLOBAL');
[~,user_name]=system('echo $USER');
netcdf.putAtt(ncid,varid,'Created_by' ,user_name(1:end-1));
netcdf.putAtt(ncid,varid,'Created_on' ,datestr(now,'ddd mmm dd HH:MM:SS yyyy '));
netcdf.endDef(ncid);

netcdf.putVar(ncid,1-1,time);
netcdf.putVar(ncid,2-1,longxy);
netcdf.putVar(ncid,3-1,latixy);
for i = 1 : length(varnames)
    netcdf.putVar(ncid,3+i-1,vars{i});
end

netcdf.close(ncid);
end