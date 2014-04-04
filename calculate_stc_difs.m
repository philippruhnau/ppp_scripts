function calculate_stc_difs(name1,name2,outname)

stc1 = mne_read_stc_file(name1);
stc2 = mne_read_stc_file(name2);

stcout = stc1;

dif_stc = size(stc1.data,2) - size(stc2.data,2);
if dif_stc < 0
    stcout.data = [stc1.data, NaN(size(stc1.data,1),abs(dif_stc))] - stc2.data;
elseif dif_stc > 0
    stcout.data = stc1.data - [stc2.data, NaN(size(stc2.data,1),abs(dif_stc))];
else
    stcout.data = stc1.data -stc2.data;
end

mne_write_stc_file(outname, stcout);