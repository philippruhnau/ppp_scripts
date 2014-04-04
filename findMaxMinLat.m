function [latencyArray] = findMaxMinLat(cfg)
% Finds peak maximum/minimum amplitude and respective latency
%
% Input:    cfg.data     - channels x timepoints x subs
%           cfg.comp     - n by 2 Array of Latency range
%           cfg.channel  - number of channels
%           cfg.path     - Experiment path
%           cfg.dir      - 'min' or 'max'
%           cfg.cond     - condition name
%           cfg.baseline - negative value for baseline in ms
%           cfg.timevar  - default: 50 ms, time delay +/- peak from grandaverage
%                          peak, around which peak is detected in individual
%                          subject
%           cfg.stafile  - name of to-be-saved file



% ms to points
timeWin = round((cfg.comp - cfg.baseline)*cfg.srate/1000);
latencyArray = zeros(size(cfg.data,3)+1,3);

if ~isfield(cfg, 'timevar')
    cfg.timevar = round(50*cfg.srate/1000);
else
    cfg.timevar = round(cfg.timevar*cfg.srate/1000);
end

for iTime = 1 : size(timeWin,1)
    if regexp(cfg.dir, 'min')
        
        % grandavg latency min
        for erp = 1:size(cfg.comp,1)
            
            writeFile = fopen(cfg.stafile, 'a+');
            if numel(cfg.channel) > 1
                [maxValue maxInd] = min(mean(mean(cfg.data(cfg.channel, timeWin(iTime,1):timeWin(iTime,2) ,:),3),1));
            else
                [maxValue maxInd] = min(mean(cfg.data(cfg.channel, timeWin(iTime,1):timeWin(iTime,2) ,:),3));
            end
            maxLatency = maxInd*1000/cfg.srate + cfg.comp(erp,1);
            % minimum peak in points
            maxLatGa = maxInd + timeWin(iTime,1);
            % for output
            latencyArray(1,:) = [93 maxValue maxLatency];
            fprintf(writeFile, '%02d \t %s \t %2.3f \t %4.0f \n', 93, cfg.cond, maxValue, maxLatency);
            
            % single sub lat min
            for iSub = 1: size(cfg.data, 3)
                if numel(cfg.channel) > 1
                    [maxValue maxInd] = min(mean(cfg.data(cfg.channel,maxLatGa-cfg.timevar:maxLatGa+cfg.timevar, iSub),1));
                else
                    [maxValue maxInd] = min(cfg.data(cfg.channel,maxLatGa-cfg.timevar:maxLatGa+cfg.timevar, iSub));
                end
                maxLatency = (maxInd + maxLatGa - cfg.timevar)*1000/cfg.srate + cfg.baseline;
                latencyArray(iSub+1,:) = [iSub maxValue maxLatency];
                fprintf(writeFile, '%02d \t %s \t %2.3f \t %4.0f \n', iSub, cfg.cond, maxValue, maxLatency);
                
                
            end
            fclose(writeFile);
        end
    elseif regexp(cfg.dir, 'max')
        
        % grandavg latency max
        for erp = 1:size(cfg.comp,1)
            writeFile = fopen(cfg.stafile, 'a+');
            if numel(cfg.channel) > 1
                [maxValue maxInd] = max(mean(mean(cfg.data(cfg.channel, timeWin(iTime,1):timeWin(iTime,2) ,:),3),1));
            else
                [maxValue maxInd] = max(mean(cfg.data(cfg.channel, timeWin(iTime,1):timeWin(iTime,2) ,:),3));
            end
            
            maxLatency = maxInd*1000/cfg.srate + cfg.comp(erp,1);
            % maximum peak in points
            maxLatGa = maxInd + timeWin(iTime,1);
            % for output
            latencyArray(1,:) = [93 maxValue maxLatency];
            fprintf(writeFile, '%02d \t %s \t %2.3f \t %4.0f \n', 93, cfg.cond, maxValue, maxLatency);
            
            % single sub lat min
            for iSub = 1: size(cfg.data, 3)
                if numel(cfg.channel) > 1
                    [maxValue maxInd] = max(mean(cfg.data(cfg.channel,maxLatGa-cfg.timevar:maxLatGa+cfg.timevar, iSub),1));
                else
                    [maxValue maxInd] = max(cfg.data(cfg.channel,maxLatGa-cfg.timevar:maxLatGa+cfg.timevar, iSub));
                end
                maxLatency = (maxInd + maxLatGa - cfg.timevar)*1000/cfg.srate + cfg.baseline;
                latencyArray(iSub+1,:) = [iSub maxValue maxLatency];
                fprintf(writeFile, '%02d \t %s \t %2.3f \t %4.0f \n', iSub, cfg.cond, maxValue, maxLatency);
                
                
            end
            fclose(writeFile);
        end
    end
end