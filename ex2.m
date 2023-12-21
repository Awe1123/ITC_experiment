clear;
clc;
% 用户输入符号概率
p = input('请输入离散信源概率分布:\n');
N = length(p);

% 获得码长向量，元素表示每个符号所对应的码长
L = ceil(-log2(p));

% 获得累加概率P及对应码字
[p_SortDescend, reflect] = sort(p, 'descend'); % 将概率从大到小进行排序

% 初始化累加概率和对应码字(字符串形式)
P = cumsum([0, p_SortDescend(1:end-1)]);
CODE = strings(1, N);

for i = 1:N
    % 初始化对应码字（数组形式）
    code = zeros(1, L(reflect(i)));
    
    % 下面计算香农码（计算累加概率的二进制数，并取前Li位）
    p_count = P(i) * 2; % p_count用于逐步的计算累加概率的二进制数
    for m = 1:L(reflect(i))
        if p_count >= 1
            code(m) = 1;
            p_count = p_count - 1;
        else
            code(m) = 0;
        end
        p_count = p_count * 2;
    end
    
    % 将香农码赋值给对应的符号
    CODE(reflect(i)) = num2str(code);
end

% 计算信源信息熵、平均码长和编码效率
H = sum(-p .* log2(p));
L_ave = sum(L .* p);
yita = H / L_ave;

% 展示输出码字、平均码长和编码效率
fprintf('编码结果:\n');
disp(['信号符号: ', num2str(1:N)]);
disp(['对应概率: ', num2str(p)]);
fprintf('对应码字:'); disp(CODE);
disp(['平均码长:', num2str(L_ave)]);
disp(['编码效率:', num2str(yita)]);
