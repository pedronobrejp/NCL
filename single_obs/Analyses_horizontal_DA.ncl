;##########################################################
;##########################################################
;######### Elaborado por João Nobre (CPTEC/INPE) ##########
;##########################################################
;##########################################################

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  cdf_analysis = addfile("/Volumes/JPNOBRE/PLOT/SINGLE_OBS/dados/wrf_inout_0.75_EnKF","r")
  cdf_bkgfs = addfile("/Volumes/JPNOBRE/PLOT/SINGLE_OBS/dados/wrfinput_d01","r")
  cdf_bk = addfile("/Volumes/JPNOBRE/DADOS/Teste_03/Membros/wrfarw.mem021","r")
  Ta = cdf_analysis->T(0,:,:,:)
  Tb = cdf_bkgfs->T(0,:,:,:)
  DT = Ta - Tb
  delete(Ta)
  delete(Tb)
  Ta = cdf_analysis->U(0,:,:,:)
  Tb = cdf_bkgfs->U(0,:,:,:)
  DU = Ta - Tb
  delete(Ta)
  delete(Tb)
  Ta = cdf_analysis->V(0,:,:,:)
  Tb = cdf_bkgfs->V(0,:,:,:)
  DV = Ta - Tb
  delete(Ta)
  delete(Tb)
  Ta = cdf_analysis->QVAPOR(0,:,:,:)
  Tb = cdf_bkgfs->QVAPOR(0,:,:,:)
  DQ = Ta - Tb
  delete(Ta)
  delete(Tb)
  DQ = DQ * 1000.0
  PSFC = cdf_analysis->PSFC(0,:,:)
  T2M = cdf_analysis->T2(0,:,:)
  Q2M = cdf_analysis->Q2(0,:,:)

  dsizes = getfiledimsizes(cdf_bk)
  nx = dsizes(2)
  ny = dsizes(3)
  nz = dsizes(4)
  lat=cdf_bk->XLAT(0,:,:)
  lon=cdf_bk->XLONG(0,:,:)
  lat_ll  = lat(0,0)
  lat_ur  = lat(ny-1,nx-1)
  lon_ll  = lon(0,0)
  lon_ur  = lon(ny-1,nx-1)

  f2dv = new ((/nz,nx/), typeof(DT))
  f2dh = new ((/ny,nx/), typeof(DT))

  rmax = -9999.0
  do k=0, nz-1
  do j=0, ny-1
  do i=0, nx-1
    if (rmax .le. DT(k,j,i)) then
       rmax=DT(k,j,i)
       imax=i
       jmax=j
       kmax=k
    end if
  end do
  end do
  end do

  print(rmax)
  print(imax)
  print(jmax)
  print(kmax)

  kmax=40

  titles = new(4,string)
  titles(0)="T inc, XY"
  titles(1)="U inc, XY"
  titles(2)="V inc, XY"
  titles(3)="Q inc, XY"

  plot = new(4,graphic)

  xwks = gsn_open_wks("ps","AmBk_0.75_EnKF_horizontal")
;  xwks = gsn_open_wks("x11","gsun01n")
  gsn_define_colormap(xwks,"cosam12")

  resources                  =  True              ; plot mods desired
  resources@gsnDraw              = True              ; Do not draw plot
  resources@gsnFrame             = True              ; Do not advance frame

  resources@cnMonoLineColor    = False
;  resources@cnFillOn    = False
  resources@cnFillOn    = True
  resources@gsnContourNegLineDashPattern = 1         ; negtive line use dash

; map
  resources@sfXArray         = lon
  resources@sfYArray         = lat

  if ( cdf_bk@MAP_PROJ .eq. 1 ) then
         mapproj = "LambertConformal"
         truelat1 = cdf_bk@TRUELAT1
         truelat2 = cdf_bk@TRUELAT2
         clon     = cdf_bk@STAND_LON
  end if
  if ( cdf_bk@MAP_PROJ .eq. 2 ) then
         mapproj = "Stereographic"
         truelat1 = cdf_bk@TRUELAT1
         truelat2 = cdf_bk@TRUELAT2
         clon     = cdf_bk@CEN_LON
         clat     = cdf_bk@CEN_LAT
  end if
  if ( cdf_bk@MAP_PROJ .eq. 3 ) then
         mapproj = "Mercator"
  end if

   resources@mpProjection            = mapproj          ; choose projection
 if ( mapproj .eq. "LambertConformal" ) then
      resources@mpLambertParallel1F     = truelat1      ; two parallels
      resources@mpLambertParallel2F     = truelat2
      resources@mpLambertMeridianF      = clon          ; central meridian
 end if
 if ( mapproj .eq. "Stereographic" ) then
      resources@mpCenterLatF         = clat
      resources@mpCenterLonF         = clon
 end if

  resources@mpLimitMode             = "Corners"
  resources@mpLeftCornerLatF        = lat_ll
  resources@mpLeftCornerLonF        = lon_ll
  resources@mpRightCornerLatF       = lat_ur
  resources@mpRightCornerLonF       = lon_ur

  resources@pmTickMarkDisplayMode = "Always"
  resources@mpFillOn              =  False             ; turn off map fill
  resources@mpOutlineDrawOrder    = "PostDraw"         ; continent outline last
  resources@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
  resources@mpGridAndLimbOn = False                  ; turn off lat/lon lines 
  resources@mpPerimOn = True
  resources@pmLabelBarDisplayMode = "Always" ; Turn on label bar.
  resources@lbPerimOn             = False    ; Turn off perimeter on label bar.
  resources@pmTickMarkDisplayMode  = "Always"     ; Turn on map tickmarks
  resources@mpDataSetName          = "Earth..4"   ; This new database contains
  resources@mpDataBaseVersion      = "MediumRes"  ; Medium resolution database
  resources@mpOutlineOn            = True         ; Turn on map outlines
  resources@mpOutlineSpecifiers    = (/"Brazil:states"/)
  resources@mpFillOn               = False        ; Turn on map fill
  resources@mpFillBoundarySets     = "National"
  resources@mpFillAreaSpecifiers   = (/"Brazil:states"/)
  resources@mpGeophysicalLineColor = "Black"
  resources@mpNationalLineColor    = "Black"
  resources@mpUSStateLineColor     = "Black"
  resources@mpGridLineColor        = "Black"
  resources@mpLimbLineColor        = "Black"
  resources@mpPerimLineColor       = "Black"
  resources@mpGridAndLimbOn        = True               ; turn on grid lines
  resources@mpGridLatSpacingF      = 5
  resources@mpGridLonSpacingF      = 5
  resources@cnFillPalette          = "BlAqGrWh2YeOrReVi22"; choose colormap
  resources@cnLinesOn              = False
  resources@cnLineLabelsOn         = False


  resources@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  resources@cnMinLevelValF       =  -0.1                 ; set min contour level
  resources@cnMaxLevelValF       =   0.1                 ; set max contour level
  resources@cnLevelSpacingF      =  0.01                 ; set contour spacing

;  resources@cnLevelSpacingF = 0.6
  plot(0) = gsn_contour_map(xwks, DT(0,:,:), resources)
  do j=0, ny-1
  do i=0, nx-1
      f2dh(j,i) = (DU(0,j,i) + DU(0,j,i+1))/2.0
  end do
  end do

  resources@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  resources@cnMinLevelValF       =  -0.1                 ; set min contour level
  resources@cnMaxLevelValF       =   0.1                 ; set max contour level
  resources@cnLevelSpacingF      =  0.01                  ; set contour spacing

;  resources@cnLevelSpacingF = 1.0
  plot(1) = gsn_contour_map(xwks, f2dh, resources)
  do j=0, ny-1
  do i=0, nx-1
      f2dh(j,i) = (DV(0,j,i) + DV(0,j+1,i))/2.0
  end do
  end do

  resources@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  resources@cnMinLevelValF       =  -0.1                 ; set min contour level
  resources@cnMaxLevelValF       =   0.1                 ; set max contour level
  resources@cnLevelSpacingF      =  0.01                  ; set contour spacing

;  resources@cnLevelSpacingF = 2.0
  plot(2) = gsn_contour_map(xwks, f2dh, resources)

  resources@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  resources@cnMinLevelValF       =  -0.1                 ; set min contour level
  resources@cnMaxLevelValF       =   0.1                 ; set max contour level
  resources@cnLevelSpacingF      =   0.01                  ; set contour spacing

;  resources@cnLevelSpacingF = 2.0
  plot(3) = gsn_contour_map(xwks, DQ(0,:,:), resources)

  resourcesP                    =  True              ; plot mods desired
  resourcesP@gsnPanelFigureStrings = titles
  resourcesP@gsnPanelFigureStringsFontHeightF = 0.01 
  resourcesP@amJust = "TopLeft"     
  resourcesP@gsnPanelFigureStringsPerimOn = True  
  gsn_panel(xwks,plot,(/3,2/),resourcesP)

  delete(plot)
  delete(resourcesP)

; plot landmask to make sure the map info is correct
;  resources@gsnDraw              = True
;  resources@gsnFrame             = True
; resources@cnLevelSpacingF = 0.2
;  resources@cnFillOn = True
;  resources@cnLineLabelsOn = False
;  resources@tiMainString = "PSFC inc, XY"
;  plotm=gsn_contour_map(xwks, PSFC(:,:), resources)

  delete(resources)
end
