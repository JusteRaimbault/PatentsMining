
# fig 1
montage figuresraw/comnum_thetaw_2004.png figuresraw/comnum_vcount_pareto_2004.png -tile 2x1 -geometry +5+0 figures/Fig1.png

# fig 2
#cp figuresraw/graph-filtered_2000-2004_kwLimit100000_dispth0_06_ethunit4_5e-05_LOWRES.png figures/Fig2.png

# fig 3
cp figuresraw/meancomsize.png figures/Fig3.png

# fig 4
cp figuresraw/all_raw_counts.png figures/Fig4.png

# fig 5
montage figuresraw/patentlevelorigs_all_semcounts.png figuresraw/patentlevelorigs_all_ts_semcounts.png figuresraw/patentlevelorigs_positive_semcounts.png figuresraw/patentlevelorigs_positive_ts_semcounts.png -tile 2x2 -geometry +5+50 figures/Fig5.png

# fig 6
#montage figuresraw/originality.png figuresraw/generality.png -tile 2x1 -geometry +5+0 figures/Fig6.png
montage figuresraw/originality.png figuresraw/generality.png -tile 2x1 -geometry 1500x900 figures/Fig6.png

# fig 7
montage figuresraw/norm-patents_all_density_semcounts.png figuresraw/norm-patents_all_ts_semcounts.png figuresraw/relative_all_density_semcounts.png figuresraw/relative_all_ts_semcounts.png -tile 2x2 -geometry +5+50 figures/Fig7.png

# fig 8
#montage figuresraw/relative_interclassif_all_density_semcounts.png figuresraw/relative_interclassif_all_ts_semcounts.png -tile 2x1 -geometry +5+0 figures/Fig8.png
montage figuresraw/relative_interclassif_all_density_semcounts.png figuresraw/relative_interclassif_all_ts_semcounts.png -tile 2x1 -geometry 1500x900 figures/Fig8.png

# fig 9
#montage figuresraw/simplemodularity.png figuresraw/overlappingmodularity.png -tile 2x1 -geometry +5+0 figures/Fig9.png
montage figuresraw/simplemodularity.png figuresraw/overlappingmodularity.png -tile 2x1 -geometry 1500x900 figures/Fig9.png

