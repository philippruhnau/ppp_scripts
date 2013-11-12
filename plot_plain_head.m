function plot_plain_head(modality, sensors, caption)

% plot_plain_head(modality,sensors)
% plots a head from the top as a circle with max. 88 eeg electrodes (field-
% trip 10-10) or max 102 meg sensors (306-Neuromag, fieldtrip) as circles; 
% captions are possible
%
% mandatory inputs:
%
% modality  - 'eeg' or 'meg'
% sensors   - 'all' takes all sensors 
%              for eeg: cell of strings of 10-10 system (e.g {'fz', 'cz'})
%              for meg: array of neuromag magnetometer channel indizes
%              (e.g. [0241 1331])
% optional input:
%
% caption   - if caption = 1, sensor names are put at each sensor

% copyright (c), 2011, P. Ruhnau, email: ruhnau@uni-leipzig.de, 2011-05-03
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%

if strcmp(modality, 'eeg')
    sen_names = {'FP1'    'FPZ'    'FP2'    'AF9'    'AF7'    'AF5'    'AF3'    'AF1'    'AFZ'    'AF2'    'AF4'    'AF6'    'AF8'    'AF10'    'F9'    'F7'    'F5'    'F3'    'F1'    'FZ'    'F2'    'F4'    'F6'    'F8'    'F10'   'FT9'    'FT7'    'FC5'    'FC3'    'FC1'    'FCZ'    'FC2'    'FC4'    'FC6'    'FT8'    'FT10'    'T9'   'T7'    'C5'    'C3'    'C1'    'CZ'    'C2'    'C4'    'C6'    'T8'    'T10'    'TP9'    'TP7'    'CP5'   'CP3'    'CP1'    'CPZ'    'CP2'    'CP4'    'CP6'    'TP8'    'TP10'    'P9'    'P7'    'P5'    'P3'    'P1'    'PZ'    'P2'    'P4'    'P6'    'P8'    'P10'    'PO9'    'PO7'    'PO5'    'PO3'    'PO1'    'POZ'    'PO2'    'PO4'    'PO6'    'PO8'    'PO10'    'O1'    'OZ'    'O2'    'I1'    'IZ'    'I2'    'VEOG'   'HEOG'};
    if ~isnumeric(sensors)
        if strcmp(sensors, 'all')
        sensors = 1:88;
        else
          [~,sensors] = intersect(sen_names,upper(sensors));
        end
    end
    coor_eeg = [0.3811    0.8313;    0.4800    0.8487;    0.5789    0.8314;    0.2449    0.8527;    0.2919    0.7811;    0.3361    0.7710;    0.3828    0.7646;    0.4311    0.7613;    0.4800    0.7602;    0.5289    0.7613;    0.5772    0.7645;    0.6238    0.7710;    0.6681    0.7811;    0.7151    0.8527;    0.1564    0.7549;    0.2211    0.7029;    0.2826    0.6869;    0.3472    0.6779;    0.4132    0.6733;    0.4800    0.6718;    0.5468    0.6733;    0.6128    0.6779;    0.6774    0.6869;    0.7389    0.7029;    0.8036    0.7548;    0.0995    0.6316;    0.1757    0.6042;    0.2506    0.5931;    0.3266    0.5872;    0.4032    0.5843;    0.4800    0.5834;    0.5568    0.5843;    0.6334    0.5872;    0.7094    0.5931;    0.7843    0.6042;    0.8605    0.6316;    0.0800    0.4949;    0.1600    0.4949;    0.2400    0.4949;    0.3200    0.4949;    0.4000    0.4950;    0.4800    0.4950;    0.5600    0.4949;    0.6400    0.4949;    0.7200    0.4949;    0.8000    0.4949;    0.8800    0.4949;    0.0995    0.3582;    0.1756    0.3856;    0.2506    0.3968;    0.3266    0.4027;    0.4032    0.4056;    0.4800    0.4065;    0.5568    0.4056;    0.6334    0.4027;    0.7094    0.3968;    0.7844    0.3856;    0.8605    0.3582;    0.1564    0.2350;    0.2211    0.2870;    0.2826    0.3030;    0.3471    0.3120;    0.4132    0.3167;    0.4800    0.3181;    0.5468    0.3167;    0.6129    0.3120;    0.6774    0.3030;    0.7389    0.2870;    0.8036    0.2350;    0.2449    0.1371;    0.2919    0.2087;    0.3361    0.2189;    0.3829    0.2251;    0.4311    0.2286;    0.4800    0.2296;    0.5289    0.2286;    0.5771    0.2251;    0.6239    0.2189;    0.6681    0.2087;    0.7151    0.1371;    0.3811    0.1585;    0.4800    0.1411;    0.5789    0.1585;    0.3564    0.0744;    0.4800    0.0527;    0.6036    0.0744;    0.6627    0.9035;  0.8018    0.9035];
    coor_eeg_trans = (coor_eeg - 0.48) ;% subtract mean of eeg_channles coordinates (0.48)
    coor = coor_eeg_trans(sensors,:);
    sNames = sen_names(sensors);
elseif strcmp(modality, 'meg')
    sen_names = [111        121         131         141         211         221         231         241         311         321         331         341         411         421         431         441         511         521         531         541         611         621         631         641         711         721         731         741         811         821         911         921         931         941        1011        1021        1031        1041        1111        1121        1131        1141        1211        1221        1231        1241        1311        1321        1331        1341        1411        1421        1431        1441        1511        1521        1531        1541        1611        1621        1631        1641        1711        1721        1731        1741        1811        1821        1831        1841        1911        1921        1931        1941        2011        2021        2031        2041        2111        2121        2131        2141        2211        2221        2231        2241        2311        2321        2331        2341        2411        2421        2431        2441        2511        2521        2531        2541        2611        2621        2631        2641];
    if strcmp(sensors, 'all')
        sensors = 1:102;
    else
         [~, sensors] = intersect(sen_names, sensors);
    end
    coor_ft =  [-67.4162   35.9167;  -53.6022   40.9891;  -62.0183   21.1770;  -74.5828   10.5958;  -50.5952   19.5193;  -38.5997   20.0439;  -41.4164    2.2832;  -53.2806   -0.2618;  -33.7905   49.9301;  -32.0143   35.2686;  -21.6800   31.3681;  -43.6845   36.5784;  -26.9980   18.1073;  -15.0848   16.4536;  -15.9309    2.4145;  -28.8247    2.8626;  -21.8615   57.9396;   -9.5067   62.1199;   -8.6161   51.8084;  -21.2405   46.3634;   -8.7824   40.6478;    3.0327   29.7609;   -3.0948   17.2009;   -9.1990   29.1314;   -3.2468    4.1938;    9.3145    4.0739;    9.3872   -8.0881;   -3.4229   -8.0199;    3.0376   63.5077;    3.0345   53.1418;   15.5048   62.1553;   27.9673   57.9087;   27.2542   46.3897;   14.6619   51.8580;    3.0329   42.1700;   14.7510   40.6541;   15.1239   29.1487;    9.2005   17.2956;   21.0150   16.4122;   32.9585   18.0621;   34.7576    2.7271;   21.8830    2.5377;   39.9589   49.8888;   49.9235   36.4147;   38.0143   35.2686;   27.6001   31.3981;   44.5997   20.0439;   56.5584   19.3877;   59.4205   -0.4195;   47.3716    2.2832;   59.7044   41.0630;   73.1193   36.3437;   80.4389   10.8359;   67.8832   21.0623;  -65.2989   -2.2073;  -61.2816  -22.9079;  -65.7028  -37.6523;  -73.9079  -14.9181;  -50.9165  -17.8122;  -39.6318  -13.8204;  -31.8961  -28.0784;  -42.8591  -33.6761;  -50.7960  -56.5823;  -51.1888  -41.5574;  -35.9030  -55.7795;  -31.4081  -69.9490;  -27.8012  -11.2687;  -15.6851  -10.1196;   -3.6001  -19.6909;  -18.4835  -24.3506;  -19.8668  -38.3500;  -14.5135  -53.8552;  -17.4285  -64.8759;  -30.2376  -45.9445;   -4.4419  -31.8082;   10.3576  -31.7897;   10.6453  -43.7907;   -4.6451  -43.7443;    2.9476  -56.3895;    3.0000  -67.8621;   14.9186  -76.9418;   -8.9871  -76.9289;   21.6415  -10.0794;   33.7865  -11.1700;   24.5015  -24.4496;    9.6417  -19.7061;   25.8528  -38.3712;   36.0789  -45.9750;   23.3633  -64.8654;   20.3299  -53.8803;   45.6448  -13.6751;   56.8123  -17.9019;   48.6942  -33.7786;   37.8961  -28.0783;   41.8126  -55.8009;   57.1719  -41.4813;   56.7046  -56.6327;   37.3202  -69.9848;   71.1374   -2.2020;   79.8222  -14.8291;   71.4901  -37.8326;   67.2202  -22.8860];
    coor_ft_trans = change_dist(coor_ft, 0,0.8); % transformation to mean of 0 with range of 0.8 to fit into circel of radius 1
    coor = coor_ft_trans(sensors,:);
    sNames = cellstr(num2str(sen_names(sensors)', '%04d'))';
end

headRadius = 2;
senCoor = coor * (headRadius+headRadius/10) *2;

ear = [[ 0.492;   0.51;  0.518; 0.5299; 0.5419;    0.54;   0.547;   0.532;    0.51;   0.484], ...
    [0.0955; 0.1175; 0.1183; 0.1146; 0.0955; -0.0055; -0.0932; -0.1313; -0.1384; -0.1199]] * 2 * headRadius; % from topoplot
nose = [[  0.09; 0.02;     0; -0.02;  -0.09], ...
    [0.4954; 0.57; 0.575;  0.57; 0.4954]] * 2 * headRadius; % from topoplot

hfig = figure;
hold on
plot3(sin(0 : 2 * pi / 100 : 2 * pi) * headRadius, cos(0 : 2 * pi / 100 : 2 * pi) * headRadius, ones(101, 1), 'k', 'linewidth', 2)
plot3(ear(:, 1), ear(:,2), ones(size(ear, 1), 1), 'k', 'linewidth', 2)
plot3(-ear(:, 1), ear(:,2), ones(size(ear, 1), 1), 'k', 'linewidth', 2)
plot3(nose(:, 1), nose(:,2), ones(size(nose, 1), 1), 'k', 'linewidth', 2)

plot3(senCoor(:, 1), senCoor(:, 2), ones(size(senCoor, 1), 1), 'ko')

if exist('caption','var')
    for iN = 1:numel(sNames)  
    text(senCoor(iN,1), senCoor(iN,2), ['   ' sNames{iN}], 'FontSize', 10, 'Color', 'k');
    end
end

set(gcf, 'Color', [1 1 1])
set(gca, 'Visible', 'off')