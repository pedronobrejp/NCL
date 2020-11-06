;----------------------------------------------------------------------
; WRF_cn_2.ncl
;
; Concepts illustrated:
;   - Plotting WRF data
;   - Plotting a cross section
;----------------------------------------------------------------------
; WRF: longitude-z cross section.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; Adaptado por Joao Nobre (CPTEC/INPE)
 
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
 load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here
  cdf_analysis = addfile("/Volumes/JPNOBRE/PLOT/SINGLE_OBS/dados/wrf_inout_0_EnKF","r")
  cdf_bkgfs = addfile("/Volumes/JPNOBRE/PLOT/SINGLE_OBS/dados/wrfinput_d01","r")
  f = addfile("/Volumes/JPNOBRE/DADOS/out_3DVar/atm/wrfout_22_2017-01-24_00:00:00","r")
;
; Read variables at given time and lat indexes
; Read W(bottom_top_stag,west_east) at Time=2, lat=15
; Read associated levels and longitudes
;

  it = 0  
 
  ntim = 0
  nlat = 150
  times = wrf_user_getvar(f,"times",-1)  ; get all time values on file
  ua = wrf_user_getvar(cdf_analysis,"T",it)
  ub = wrf_user_getvar(cdf_bkgfs,"T",it)
  DT = ua(:,nlat,:)-ub(:,nlat,:)
  znw   = cdf_analysis->ZNU(ntim,:)                 ; znw(bottom_top_stag)
  lon   = cdf_analysis->XLONG(ntim,nlat,:)          ; lon(west_east)    

;---Add/change meta data to conform to netCDF convention standards
  lon@units = "degrees_east"            ; CF recommended units
  DT!0       = "lev"                     ; name dimensions
  DT&lev     =  znw                      ; assign values to named dimensions
  DT!1       = "lon"
  DT&lon     =  lon

;---Use simple array syntax [like f90] to change units
  DT@units   = "T(Kelvin)"                                             

;
; For labeling purposes only, determine the average 
; latitude of the cross section
;
  lat_avg = avg(f->XLAT(ntim,nlat,:))       ; avg is a built in function

;
; A "BlWhRe" color map is often selected when plus/minus are 
; of interest
; The "symMinMaxPlt" procedure determines contour limits that 
; are symmetric.
;
  wks = gsn_open_wks("png","/Volumes/JPNOBRE/PLOT/SINGLE_OBS/WRF_cn_T")

  res                       = True            ; plot mods desired
  res@gsnMaximize           = True            ; maximize plot size
  res@cnFillOn              = True            ; turn on color
  res@cnFillPalette         = "BlAqGrWh2YeOrReVi22"        ; set the color map
  res@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  res@cnMinLevelValF       =  -0.1                 ; set min contour level
  res@cnMaxLevelValF       =   0.1                 ; set max contour level
  res@cnLevelSpacingF      =  0.01                 ; set contour spacing
  res@cnLinesOn             = False           ; turn off contour lines
  res@trYReverse            = True            ; reverse y axis
  res@tmXBTickSpacingF      = 5.              ; force labeling every 10 deg lon
;  symMinMaxPlt(DT, 14, False, res)

  plot             = gsn_csm_contour(wks,DT,res)
end

