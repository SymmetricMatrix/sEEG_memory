function oS = cluster_peaks_dynamic2(oS)
% Second Helper function to cluster peaks across time
% Author: Luc Wilson (2022)
    pthr = oS.options.proximity_threshold;
    for chan = 1:length(oS.channel)
        clustLead = [];
        nCl = 0;
        oS.channel(chan).clustered_peaks = struct();
        times = unique([oS.channel(chan).peaks.time]);
        all_peaks = oS.channel(chan).peaks;
        for time = 1:length(times)
            time_peaks = all_peaks([all_peaks.time] == times(time));
            % Initialize first clusters
            if time == 1
                nCl = length(time_peaks);
                for Cl = 1:nCl
                    oS.channel(chan).clustered_peaks(Cl).cluster = Cl;
                    oS.channel(chan).clustered_peaks(Cl).peaks(Cl) = time_peaks(Cl);
                    clustLead(Cl,1) = time_peaks(Cl).time;
                    clustLead(Cl,2) = time_peaks(Cl).center_frequency;
                    clustLead(Cl,3) = time_peaks(Cl).amplitude;
                    clustLead(Cl,4) = time_peaks(Cl).st_dev;
                    clustLead(Cl,5) = Cl;
                end
                continue
            end
            
            % Cluster "drafting stage": find points that make good matches to each cluster.  
            for Cl = 1:nCl
                match = abs([time_peaks.center_frequency]-clustLead(Cl,2))./clustLead(Cl,4) < pthr;
                idx_tmp = find(match);
                if any(match)
                    % Add the best candidate peak 
                    % Note: Auto-adds only peaks, but adds best candidate
                    % for multiple options
                    [tmp,idx] = min(([time_peaks(match).center_frequency] - clustLead(Cl,2)).^2 +...
                            ([time_peaks(match).amplitude] - clustLead(Cl,3)).^2 +...
                            ([time_peaks(match).st_dev] - clustLead(Cl,4)).^2);
                    oS.channel(chan).clustered_peaks(clustLead(Cl,5)).peaks(length(oS.channel(chan).clustered_peaks(clustLead(Cl,5)).peaks)+1) = time_peaks(idx_tmp(idx)); 
                    clustLead(Cl,1) = time_peaks(idx_tmp(idx)).time;
                    clustLead(Cl,2) = time_peaks(idx_tmp(idx)).center_frequency;
                    clustLead(Cl,3) = time_peaks(idx_tmp(idx)).amplitude;
                    clustLead(Cl,4) = time_peaks(idx_tmp(idx)).st_dev;
                    % Don't forget to remove the candidate from the pool
                    time_peaks(idx_tmp(idx)) = [];
                end
            end
            % Remaining peaks get sorted into their own clusters
            if ~isempty(time_peaks)
                for peak = 1:length(time_peaks)
                    nCl = nCl + 1;
                    Cl = nCl;
                    clustLead(Cl,1) = time_peaks(peak).time;
                    clustLead(Cl,2) = time_peaks(peak).center_frequency;
                    clustLead(Cl,3) = time_peaks(peak).amplitude;
                    clustLead(Cl,4) = time_peaks(peak).st_dev;
                    clustLead(Cl,5) = Cl;
                    oS.channel(chan).clustered_peaks(Cl).cluster = Cl;
                    oS.channel(chan).clustered_peaks(Cl).peaks(length(oS.channel(chan).clustered_peaks(clustLead(Cl,5)).peaks)+1) = time_peaks(peak); 
                end
            end     
            % Sort clusters based on most recent
            clustLead = sortrows(clustLead,1,'descend');
        end
    end
end
