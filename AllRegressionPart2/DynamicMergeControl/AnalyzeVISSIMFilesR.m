clc;
clear;

accumulatedGR=[];
currentFolder= pwd;

for runCount=1:60
    display(runCount)
    fileLocation=strcat(currentFolder,'\',num2str(runCount),'\InputVector.att');
    Input= dlmread(fileLocation,'\t');
    
    greenRatioVector= [];
    for i=1:3
        fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUC_Run',num2str(i),'.att');
        greenRatio=dlmread(fileLocation);
        greenRatioVector= [greenRatioVector greenRatio(:,2)];
    end
    
    greenRatioVector= mean(greenRatioVector(2:end,:)')';
    
    fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUCWithRamp_003_Queue Results.att');
    if exist(fileLocation, 'file')==0
        %iteration 3 files do not exist so assign it as iteration 2 file
        fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUCWithRamp_002_Queue Results.att');
    end
    if exist(fileLocation, 'file')==0
        %even second iteration file doesn't exist
        display('No file found');
        exit;
    end
    fid=fopen(fileLocation,'r');
    fullFileScan=textscan(fid,'%s');
    splitFileScan=fullFileScan{1};
    
    noOfQueueCounters=2;
    record1=[]; %for the ramp
    record2=[]; %for the main line

    queueEvaluationStep= 5;
    for i=1:length(splitFileScan)
        row=splitFileScan{i};
        if length(row)<3
            %Empty rows in the file. Ignore these
            continue;
        end

        if sum(row(1:3)=='AVG')==3
            %Only concerned with avg of three simulations
            allColumns=strsplit(row,';');
            if length(allColumns)<6
               %the row entry doesn't have data
               continue;
            end
            subColumnsColumn2= strsplit(allColumns{2},'-');
            index= str2double(allColumns{3});

            if index==1
                record1= [record1; index, str2double(subColumnsColumn2{1}),...
                    str2double(subColumnsColumn2{2}), str2double(allColumns{4}),...
                    str2double(allColumns{5}), str2double(allColumns{6})];
            end
            if index==2
                record2= [record2; index, str2double(subColumnsColumn2{1}),...
                    str2double(subColumnsColumn2{2}), str2double(allColumns{4}),...
                    str2double(allColumns{5}), str2double(allColumns{6})];
            end

        end
    end
    
    maxQueueLength= zeros(2,1); % two queue counters
    maxQueueLength(1) = max(record1(2:3,5)); %ignoring queue from 0-300 and 2700-3600
    maxQueueLength(2) = max(record2(2:3,5));
    
    avgQueueLength= zeros(2,1); %two queue counters
    avgQueueLength(1)= mean(record1(2:3,4));
    avgQueueLength(2)= mean(record2(2:3,4));
    
    %indexQSpillsRamp= record1(300/queueEvaluationStep+1:2700/queueEvaluationStep,5)> 244;
    %indexQSpillsMainline= record2(300/queueEvaluationStep+1:2700/queueEvaluationStep,5)> 402;
    %percentTimeQSpillsRamp= sum(indexQSpillsRamp)/length(indexQSpillsRamp);
    %percentTimeQSpillsMainline= sum(indexQSpillsMainline)/length(indexQSpillsMainline);
    
    %if percentTimeQSpillsRamp>0 || percentTimeQSpillsMainline>0
    %    display('spill');
    %end
%     
%     noOfTimeQexceedsMainline=0;
%     
%     newrecord1=[]; newrecord2=[]; newrecord3=[]; newrecord4=[];
%     intv= 900/queueEvaluationStep;
% 
%     for i=1:5
%         newrecord1=[newrecord1; 1, (i-1)*900, i*900, mean(record1((i-1)*intv+1:i*intv,4)), max(record1((i-1)*intv+1:i*intv,5)), mean(record1((i-1)*intv+1:i*intv,6))];
%         newrecord2=[newrecord2; 2, (i-1)*900, i*900, mean(record2((i-1)*intv+1:i*intv,4)), max(record2((i-1)*intv+1:i*intv,5)), mean(record2((i-1)*intv+1:i*intv,6))];
%         newrecord3=[newrecord3; 3, (i-1)*900, i*900, mean(record3((i-1)*intv+1:i*intv,4)), max(record3((i-1)*intv+1:i*intv,5)), mean(record3((i-1)*intv+1:i*intv,6))];
%         newrecord4=[newrecord4; 4, (i-1)*900, i*900, mean(record4((i-1)*intv+1:i*intv,4)), max(record4((i-1)*intv+1:i*intv,5)), mean(record4((i-1)*intv+1:i*intv,6))];
%     end
%     i=i+1;
%     newrecord1=[newrecord1; 1, (i-1)*900, i*900, mean(record1((i-1)*intv+1:end,4)), max(record1((i-1)*intv+1:end,5)), mean(record1((i-1)*intv+1:end,6))];
%     newrecord2=[newrecord2; 2, (i-1)*900, i*900, mean(record2((i-1)*intv+1:end,4)), max(record2((i-1)*intv+1:end,5)), mean(record2((i-1)*intv+1:end,6))];
%     newrecord3=[newrecord3; 3, (i-1)*900, i*900, mean(record3((i-1)*intv+1:end,4)), max(record3((i-1)*intv+1:end,5)), mean(record3((i-1)*intv+1:end,6))];
%     newrecord4=[newrecord4; 4, (i-1)*900, i*900, mean(record4((i-1)*intv+1:end,4)), max(record4((i-1)*intv+1:end,5)), mean(record4((i-1)*intv+1:end,6))];
% 
%     
%     sumQueueLength= zeros(3,1); %I know there are two queue counter locations
%     sumQueueStops= zeros(3,1);
%     maxQueueLength= zeros(3,1);
%     noOfTimeQexceedsRampLength=0;
%     noOfTimeQexceedsMainline=0;
%     count=0;
%     
%     for i=1:length(splitFileScan)
%         b=splitFileScan{i};
%         if length(b)<3
%             continue;
%         end
%         
%         if sum(b(1:3)=='AVG')==3
%             %Only concerned with avg of three simulations
%             c=strsplit(b,';');
%             if  length(c)<5
%                continue; %empty row 
%             end
%             if str2num(c{2}(1))==0
%                 continue; %don't want the results from first interval as they are skewed
%             end
%             index= str2num(c{3});
%             count=count+1;
%             sumQueueLength(index)=sumQueueLength(index)+str2double(c{4});
%             if index==1
%                %it's a ramp queue
%                if  str2double(c{5})>244
%                    noOfTimeQexceedsRampLength=noOfTimeQexceedsRampLength+1;
%                end
%             end
%             if index==3
%                %it's a ramp queue
%                if  str2double(c{5})>402
%                    noOfTimeQexceedsMainline=noOfTimeQexceedsMainline+1;
%                end
%             end
%             if maxQueueLength(index)<str2double(c{5})
%                 maxQueueLength(index)=str2double(c{5});
%             end
%             sumQueueStops(index)=sumQueueStops(index)+str2double(c{6});
%         end
%     end
%     avgQueueLength= sumQueueLength*3/count;
%     percentTimeQexceedsMainline = noOfTimeQexceedsMainline*3/count;
    
    fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUCWithRamp_003_Vehicle Travel Time Results.att');
    if exist(fileLocation, 'file')==0
        %iteration 3 files do not exist so assign it as iteration 2 file
        fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUCWithRamp_002_Vehicle Travel Time Results.att');
    end
    if exist(fileLocation, 'file')==0
        %even second iteration file doesn't exist
        display('No file found');
        exit;
    end
    
    fid=fopen(fileLocation,'r');
    fullFileScan=textscan(fid,'%s');
    splitFileScan=fullFileScan{1};
    
    %sumTravelTime= zeros(2,1); %I know there is two veh tt sensor
    count=0;
    TSTT=0;
    sumTravelTime=0;
    for i=1:length(splitFileScan)
        b=splitFileScan{i};
        if length(b)<3
            continue;
        end
        
        if sum(b(1:3)=='AVG')==3
            %Only concerned with avg of three simulations
            c=strsplit(b,';');
            if  length(c)<5
               continue; %empty row 
            end
            d=strsplit(c{2},'-');
            if str2num(d{1})==0 || str2num(d{1})>=2700
                %Ignoring the first timestep and last 15min 
                continue; 
            end
            index= str2num(c{3});
            sumTravelTime= sumTravelTime+str2double(c{5});
            TSTT= TSTT+ str2double(c{5})*str2double(c{4});
            count=count+1;
        end
    end
    avgTravelTime = sumTravelTime/count;
    %{
    fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUCWithRamp_003_Delay Results.att');
    if exist(fileLocation, 'file')==0
        %iteration 3 files do not exist so assign it as iteration 2 file
        fileLocation=strcat(currentFolder,'\',num2str(runCount),'\DLUCWithRamp_002_Delay Results.att');
    end
    if exist(fileLocation, 'file')==0
        %even second iteration file doesn't exist
        display('No file found');
        exit;
    end
    fid=fopen(fileLocation,'r');
    fullFileScan=textscan(fid,'%s');
    splitFileScan=fullFileScan{1};
    
    sumVehDelay= zeros(2,1); %I know there is two veh delay sensor
    sumVehStoppedDelay=zeros(2,1);
    count=0;
    
    for i=1:length(splitFileScan)
        b=splitFileScan{i};
        if length(b)<3
            continue;
        end
        
        if sum(b(1:3)=='AVG')==3
            %Only concerned with avg of three simulations
            c=strsplit(b,';');
            if  length(c)<5
               continue; %empty row 
            end
            d=strsplit(c{2},'-');
            if str2num(d{1})>=2700
                %Ignoring the last 15min 
                continue; 
            end
            index= str2num(c{3});
            sumVehDelay(index)= sumVehDelay(index)+str2double(c{10});
            sumVehStoppedDelay(index)=sumVehStoppedDelay(index)+str2double(c{4});
            count=count+1;
        end
    end
    avgVehDelay = sumVehDelay*2/count;
    avgStoppedVehDelay = sumVehStoppedDelay*2/count;
    %}
%     
%     accumulatedGR(runCount,13)=sumQueueLength_1/90;
%     accumulatedGR(runCount,14)=maxQueueLength_1;
%     accumulatedGR(runCount,15)=sumQueueStops_1/90;
%     
%     accumulatedGR(runCount,16)=sumQueueLength_2/90;
%     accumulatedGR(runCount,17)=maxQueueLength_2;
%     accumulatedGR(runCount,18)=sumQueueStops_2/90;
%     
%     fileLocation=strcat(currentFolder,'\',num2str(runCount),'\atm_2_exit_3_lanes_large_network_001_Vehicle Travel Time Results.att');
%     fid=fopen(fileLocation,'r');
%     fullFileScan=textscan(fid,'%s');
%     splitFileScan=fullFileScan{1};
%     
%     travelTime=zeros(6,1); %stores the travel time for first and second half of corridor for the three hours
%     %tt_1 is first half first hour, tt_1 is second half first hour and
%     %likewise
%     for i=51:56
%         b=splitFileScan{i};
%         c=strsplit(b,';');
%         travelTime(i-50)= str2double(c{5});
%     end
%     
%     accumulatedGR(runCount,19:24)=travelTime';
    
    accumulatedGR= [ accumulatedGR; runCount,   Input', mean(greenRatioVector), maxQueueLength', avgTravelTime', ...
        avgQueueLength', TSTT]; %check this
    
end
v={'runcount','Input MainLine', 'Input Ramp', 'Bottleneck Speed', 'Percent Open', 'Max Queue Ramp', 'Max Queue Mainline', 'TT mainline',  'Avq Queue Ramp', 'Avg Queue Mainline', 'TSTT'};
%accumulatedGR=[v; accumulatedGR];
dlmwrite('CompiledResult.txt',accumulatedGR,'\t');
xlswrite('AllResults.xlsx',accumulatedGR);

fclose all