clear
format long;
data = importdata("../../../../Documents/PartIILogs/remote_worker_sequential_latencies.log", ' ');
data2 = importdata("../../../../Documents/PartIILogs/PureGit/single_throughput_pure_git_001.log", ' ');
data3 = importdata("../../../../Documents/PartIILogs/PureGit/single_throughput_pure_git_01.log", ' ');

%calculate latencies
result = data(:,2) - data(:,1);
result2 = data2(:,2) - data2(:,1);
result3 = data3(:,2) - data3(:,1);
%calculate average of every n items

n = 50;
s1 = size(result, 1);
M  = s1 - mod(s1, n);
y  = reshape(result(1:M), n, []);
result = transpose(sum(y, 1) / n);

s2 = size(result2, 1);
M2  = s2 - mod(s2, n);
y2  = reshape(result2(1:M2), n, []);
result2 = transpose(sum(y2, 1) / n);

s3 = size(result3, 1);
M3  = s3 - mod(s3, n);
y3  = reshape(result3(1:M3), n, []);
result3 = transpose(sum(y3, 1) / n);


%plot
transactions = n*(1:length(result));
transactions2 = n*(1:length(result2));
transactions3 = n*(1:length(result3));
plot(transactions, result, transactions2, result2, transactions3, result3);
xlabel("Blockchain Size, transactions");
ylabel("Latency, s");
l = legend("Using Ezirmin pull", "Using Git (~70 txns/s)", "Using Git (~10 txns/s)");
l.Location = 'northwest';
