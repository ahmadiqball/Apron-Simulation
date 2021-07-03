clear all
clc

%By Ahmad Iqbal Yahya


%---------Single Simulation of Aircraft Operation in Apron-----------%

%---------Input Section----------%
%Departure distribution is triangular distribution
%With low is smallest value in data, high is biggest value in data, and
%peak is the peak of distribution
low = 30;
peak = 45;
high = 90;
%Time Running on Simulation (in hour)
hour = 3;
%Appron Size
aprSize = 12;


%------Departure Distribution-----%
pd = makedist('Triangular','a',low,'b',peak,'c',high);

%--------------Time---------------%
minutes = hour*60;
timestamp = 0:5:minutes;

%-------------Arrival--------------%
%This code section is determining on how much aircraft will arive at time t
%the arrival distribution is defined as a function writen at very bottom of
%this script. This section also record arrival time of every incoming
%aircraft. counter1 is used to indexing.
counter1 = 1;
for i = 1:length(timestamp)
    arv(i) = arrival();
    totalArv(i) = sum(arv);
    if arv(i) == 1
        arvTime(counter1) = timestamp(i);
        counter1 = counter1+1;
    elseif arv(i) == 2
        arvTime(counter1) = timestamp(i);
        arvTime(counter1+1) = timestamp(i);
        counter1 = counter1+2;
    end
end

%------------Ground Time------------%
%This code section is determining on how much time will spend by every single 
%aircraft inside the apron.
groundTime = zeros(max(totalArv),1);
for i = 1:max(totalArv)
    groundTime(i) = random(pd);
end

%-----------Waiting time------------%
%apron is array that represents the apron in reality with ceratin slot
apron = zeros(aprSize,1);
count = 0;

%Create simulation inside the apron, it's similiar with multiserver
%ququeing process, with the apron as a servers.
for i=1:length(timestamp)
    %At time t there's ceratin incoming aircraft, this code tell the
    %aircraft should get in to which apron, if all apron occupied it's also
    %tell how long the aircraft should wait to get into apron.
    for j=1:arv(j)
        count=count+1;
        a = find(apron==min(apron));
        server(count) = min(a);
        waitTime(count) = apron(server(count));
        apron(server(count)) = apron(server(count)) + groundTime(count);
    end
    
    %Simulate time passed by aircraft inside apron, so it's ground time
    %will reduce, and when the value <0 it's mean the aircraft hava been
    %depart and its used apron is empty and reset to zero.
    apron = apron - 5;
    maskApr = apron<0;
    apron(maskApr) = 0;
end



%------------Departure-------------%
%Define when every single aircraft will depart. Departure time is equal
%with summation of its arrival time, waiting time, and ground time(time
%spend inside apron).
for i = 1:max(totalArv);
    depTime(i) = arvTime(i) + waitTime(i) + groundTime(i);
end

%Count total departed aircraft as time increasing
%maxTime, is time spent until all aircraft departed
%departure array is copy of depTime array, because that array will have
%change in value in this process, so i can keep the original value.
maxTime = ceil(max(depTime)/10)*10;
if maxTime > minutes
    time = 0:5:maxTime;
elseif maxTime <= minutes
    time = 0:5:minutes;
end
departure = depTime;

%This code simulate as time passed, the remaining value of aircraft departure time
%will be reduced, when it reach <= 0 it's mean the aircraft have depart.
%Then the code will record how much aircraft's remaining departure time
%that reach zero at certain time. Then using masking process to delete the departure time that
%reach zero because its related aircraft have depart. The code also count
%total aircraft that have depart by time passed.
for i=1:length(time)
    if min(departure) <= 0
        depCount(i) = length(find(departure<=0));
        totalDep(i) = sum(depCount);
        maskDep = departure>0;
        departure = departure(maskDep);
    else
        depCount(i) = length(find(departure<=0));
        totalDep(i) = sum(depCount);
    end
    departure = departure - 5;
end

%-----------Apron Occupancy-----------%
%This code will calculate how much slot in apron being used at certain
%time.
 for i = 1:length(timestamp);
    occupancy(i) = totalArv(i) - totalDep(i);
 end
 
%----------Waiting Aricraft------------%
%This code will calculate how much aircraft in waiting line at certain
%time.
for i = 1:length(timestamp);
    if occupancy(i) > 10
        waitCount(i) = occupancy(i) - 10;
    else
        waitCount(i) = 0;
    end
end

%------------Statistics-----------------%
%This statistics shows the average waiting aircraft, maximum waiting
%aicraft,average waiting time, and maximum waiting time of systems. 
waitAvg = mean(waitCount);
maxWait = max(waitCount);
waitTimeAvg = mean(waitTime);
maxWaitTime = max(waitTime);
apronCapacity = max(totalArv)/(max(depTime)/60);
fprintf('Average Waiting Aircraft: %d aircraft\nMaximum Waiting Aircraft: %d aircraft\n',waitAvg,maxWait)
fprintf('Average Waiting Time: %d minutes\nMaximum Waiting Time: %d minutes\n',waitTimeAvg,maxWaitTime)
fprintf('Apron Capacity: %d aircraft/hour\n',apronCapacity)

%--------------Figure-------------------%
%This section is plotting every data needed to plot.
figure(1)
stairs(timestamp,occupancy)
title('Aircraft in System')
xlabel('Time')
ylabel('Number of Aircraft')

figure(2)
stairs(timestamp,waitCount)
title('Waiting Aircraft')
xlabel('Time')
ylabel('Number of Waiting Aircraft')

figure(3)
stairs(timestamp,totalArv)
hold on
stairs(time,totalDep)
hold off
title('Total Arrival and Departure')
xlabel('Time')
ylabel('Number of Aircraft')
legend({'Total Arival','Total Departure'},'Location','northwest')

%-------Arrival distribution--------%
%The arrival distribution using uniformly distribution, this section is in
%bellow because it's a function.
function arr = arrival()
    r = rand();
    if r <= 0.5
        arr = 0;
    elseif r <= 0.8
        arr = 1;
    else
        arr = 2;
    end
end


