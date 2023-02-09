function posterior_comparison, xray_res, noxray_res, agn_model_lum
;+
; Name
; ----
;   POSTERIOR_COMPARISON
;
; Purpose
; -------
;   Create a cornerplot figure comparing the posterior distributions
;   for the AGN parameters of J033226.49-274035.5 when we fit with
;   and without the X-ray model.
;
; Input
; -----
;   N/A
;
; Output
; ------
;   Saves the figure to an EPS file.
;
; Dependencies
; ------------
;   IDL AstroLib & Keith's corner plot routine
;
;-

    compile_opt IDL2

    ; xray_res_dir = 'xray/lightning_output/'
    ; noxray_res_dir = 'noxray/lightning_output/'
    ;
    ; xray_res_fname = (file_search(xray_res_dir + 'postprocessed_data_*.fits.gz'))[-1]
    ; noxray_res_fname = (file_search(noxray_res_dir + 'postprocessed_data_*.fits.gz'))[-1]
    ;
    ; xray_res = mrdfits(xray_res_fname, 1)
    ; noxray_res = mrdfits(noxray_res_fname, 1)

    ; Since the AGN model luminosity is not an output when we use the qsosed model,
    ; we've computed it manually ahead of time, and loading it now. Like a TV chef.
    ; restore, 'xray/AGN_model_results.sav' ; defines AGN_MODEL_RESULTS

    log_L_AGN_x = alog10(agn_model_lum.LBOL_AGN_MODEL)

    ; Build the array for the corner plot function
    x_arr = transpose([[reform(xray_res.AGN_MASS) / 1.d8],$
                       [reform(xray_res.AGN_LOGMDOT)],$
                       [reform(xray_res.NH) / 1e2],$
                       [log_L_AGN_x],$
                       [reform(xray_res.AGN_COSI)]])

    nox_arr = transpose([[randomn(seed, n_elements(xray_res.AGN_MASS))/1000],$
                         [randomn(seed, n_elements(xray_res.AGN_MASS))/1000],$
                         [randomn(seed, n_elements(xray_res.AGN_MASS))/1000],$
                         [reform(noxray_res.LOG_L_AGN)],$
                         [reform(noxray_res.AGN_COSI)]])

    full_arr = [[[nox_arr]], [[x_arr]]]

    labels = ['$M_{\rm SMBH}$ $[10^8$ $M_{\odot}]$',$
              'log !sm!r!A .!n!3 ',$
              '$N_H$ $[10^{22}$ $cm^{-2}]$',$
              '$log_{10}(L_{\rm AGN}$ $[L_{\odot}]$)',$
              'cos $i_{AGN}$']

    range_arr = [[1.2, 1.5],$
                 [-0.55, -0.1],$
                 [0.1, 0.75],$
                 [11.9, 12.6],$
                 [0.53, 0.99]]

    p = window(dimension=[860, 800])
    p = corner_plot(full_arr, labels,$
                    distribution_range=range_arr,$
                    /NORMALIZE,$
                    /SHOW_MEDIAN,$
                    CONTOUR_LEVELS=[0.68, 0.95],$
                    CONTOUR_SMOOTH=3,$
                    TICKINTERVAL=[0.1, 0.2, 0.25, 0.3, 0.1],$
                    DISTRIBUTION_COLOR=['orange', 'blue'],$
                    DISTRIBUTION_THICK=2,$
                    CONTOUR_THICK=2,$
                    font_size=10,$
                    position=[0.08, 0.08, 0.92, 0.98],$
                    /current)

    t1 = text(0.75, 0.82, 'J033226.49-274035.5', /CURRENT, /NORMAL, font_size=14, alignment=0.5)

    x = objarr(2)
    x[0] = plot([0, 0], [0, 0], color='blue', thick=2, name='with X-ray data', position=[2, 2, 3, 3], /current)
    x[1] = plot([0, 0], [0, 0], color='orange', thick=2, name='without X-ray data', position=[2, 2, 3, 3], /current)
    lgnd = legend(target=x, transparency=30, position=[0.75, 0.80], $
                  vertical_alignment=1, horizontal_alignment=0.5, font_size=14)

    ;p.save, 'figure_J033226_corner_params.eps'

    ;p.close

    return, p

end
