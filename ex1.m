clear;
clc;
% 1. 绘制二元熵函数曲线
p = linspace(0.01, 1, 100);
h = -(p .* log2(p) + (1-p) .* log2(1-p));
figure;
plot(p, h);
title('二元熵函数曲线');
xlabel('p');
ylabel('H(p)');

% 2. 绘制三元熵函数曲线
p = linspace(eps, 1-eps, 100);
q = linspace(eps, 1-eps, 100);
[P, Q] = meshgrid(p, q);
P_Q=P + Q;
for n=1:100
    for m=1:100
        if P_Q(n, m)>=1
            Q(n, m)=nan;
        end
    end
end
H = -P.*log2(P) - Q .* log2(Q) - (1-P-Q) .* log2(1-P-Q);
figure;
mesh(P, Q, H);
title('三元熵函数曲线');

% 3.1 读入一篇英文字母组成的信源文档
file_path = 'message.txt'; % 替换为实际文本文件的路径
source_text = fileread(file_path);

% 3.2 计算字母与空格的概率分布
unique_chars = unique(source_text);
total_chars = numel(source_text);

prob_distribution = zeros(1, numel(unique_chars));
for i = 1:numel(unique_chars)
    prob_distribution(i) = sum(source_text == unique_chars(i)) / total_chars;
end

% 3.3 计算信源的熵
entropy = -sum(prob_distribution .* log2(prob_distribution));

% 3.4 输出结果
disp('字母与空格的概率分布：');
disp([unique_chars]);
disp([prob_distribution]);

disp(['信源的熵：', num2str(entropy)]);
