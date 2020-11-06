;##################################################################################################;
;################################ Dezembro/2019 - Eder P. Vendrasco ###############################;
;##################################################################################################;
;################################ Adaptado por João Nobre em 2021   ###############################;
;Foram corrigidos alguns erros obtidos
;Coverte arquivo .nc do WRF para .ctl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

InterpMethod= "bilinear"                      ; define interpolation method

srcDirName  = "/Volumes/JPNOBRE/dados/Teste_03/MERRA2_BK/EnKF_off"
srcFileName = "wrf_inout"
srcFilePath =  srcDirName + "/" + srcFileName

sfile = addfile(srcFilePath,"r")
    
ua3d = wrf_user_getvar(sfile,"ua",-1)       ; On mass grid 
va3d = wrf_user_getvar(sfile,"va",-1)       ; On mass grid 
ta3d = wrf_user_getvar(sfile,"T",-1)        ; On mass grid
pa3d = wrf_user_getvar(sfile,"PSFC",-1)        ; On mass grid
pres = wrf_user_getvar(sfile,"pressure",-1) ; On mass grid 


ua = wrf_interp_3d_z(ua3d,pres,850.0)
va = wrf_interp_3d_z(va3d,pres,850.0)
ta = wrf_interp_3d_z(ta3d,pres,850.0)
pa = pa3d

dimsd = dimsizes(ua)
print(dimsd)

    lat2d = sfile->XLAT(0,:,:)               ; (south_north,west_east)
    lon2d = sfile->XLONG(0,:,:)

;---Create the destination rectilinear lat[*]/lon[*] arrays
;    lat = fspan(min(lat2d), max(lat2d) ,nlat)
;    lon = fspan(min(lon2d), max(lon2d) ,nlon)
    lat = fspan(-21.0,3.0,300)
    lon = fspan(-54.0,-23.0,359)

    dims  = dimsizes(lat)
    print(dims)
    nlat  = dims(0)
    dims  = dimsizes(lon)
    nlon  = dims(0)

    dx = (lon(nlon-1)-lon(0))/(nlon-1)
    dy = (lat(nlat-1)-lat(0))/(nlat-1)
    
;    printMinMax(lat,0)
;    printMinMax(lon,0)
;    print(dimsizes(lat))
;    print(dimsizes(lon))
    print(dx)
    print(dy)

    Opt                = True
    Opt@SrcTitle       = "WRF grid"   ; optional
    Opt@WgtFileName    = "WRF_to_Rect.WgtFile_"+InterpMethod+".nc"

;---Source grid options
    Opt@SrcFileName    = "WRF.SCRIP_grid_description.nc"         ; Name of source and
    Opt@SrcRegional    = True
    Opt@SrcGridLat     = lat2d
    Opt@SrcGridLon     = lon2d

;---Destination grid options
    Opt@DstFileName    = "Rectilinear.SCRIP_grid_description.nc" ; destination files
    Opt@DstGridType    = "rectilinear"
    Opt@DstGridLat     = lat
    Opt@DstGridLon     = lon
    Opt@DstRegional    = True

;---Specify other options  
    Opt@ForceOverwrite = True
    Opt@InterpMethod   = InterpMethod

;---Wgt File: WRF to Rectilinear
    wgtDirName  = "./"
    wgtFileName = "WRF_to_Rect.WgtFile_"+InterpMethod+".nc"
    wgtFilePath =  wgtDirName + wgtFileName

;---Perform the regrid: WRF ==> rectilinear (_reclin) 
;    if (isfilepresent(wgtFilePath))
;        print("Using Weights.")
;        ua_regrid = ESMF_regrid_with_weights(ua,wgtFilePath,False)
;        va_regrid = ESMF_regrid_with_weights(va,wgtFilePath,False)
;     else
;        print("NOT Using Weights.")
        ua_regrid = ESMF_regrid(ua, Opt)     ; Do the regridding for ua   
        va_regrid = ESMF_regrid(va, Opt)     ; Do the regridding for va
        ta_regrid = ESMF_regrid(ta, Opt)     ; Do the regridding for va
        pa_regrid = ESMF_regrid(pa, Opt)     ; Do the regridding for va   
;    end if
    
;---Reset 0 values to missing values.
;    ua_regrid@_FillValue     = default_fillvalue(typeof(ua_regrid))
    ua_regrid@_FillValue     = -9.99e+08
    va_regrid@_FillValue     = -9.99e+08
    ta_regrid@_FillValue     = -9.99e+08
    pa_regrid@_FillValue     = -9.99e+08
;    ua_regrid                = where(ua_regrid.eq.0.0,ua_regrid@_FillValue,\
;                                     ua_regrid)

;    printVarSummary(ua_regrid)
;    print("ua_regrid: min="+min(ua_regrid)+"   max="+max(ua_regrid))
;    nmsg = num(ismissing(ua_regrid))
;    print("nmsgRectilinearGrid="+nmsg)

    destDirName    = "./"
    destFileNameua = "teste_wrf.dat"
    destFilePathua = destDirName + "/" + destFileNameua

    fbindirwrite(destFilePathua,ua_regrid(:,:,:,:) ) 
    fbindirwrite(destFilePathua,va_regrid(:,:,:,:) )
    fbindirwrite(destFilePathua,ta_regrid(:,:,:,:) ) 
    fbindirwrite(destFilePathua,pa_regrid(0,:,:) )
    


