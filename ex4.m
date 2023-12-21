clear;
clc;
% 算法参数设置
err = 1e-15;             % 误差门限参数设置
C_current = -1e30;       % 初始信道容量设置
K = 10000;               % 最大迭代次数设置
fag = 1e-50;             % 设定的高次小量用于替换0

% 输入部分
% 键盘输入信源符号个数和新宿符号个数
r = input('请输入信源符号个数:\n');
s = input('请输入信宿符号个数:\n');

% 初始化转移概率矩阵
Pcc = zeros(r, s);

% 逐个输入转移概率
for i = 1:r
    for j = 1:s
        Pcc(i, j) = input(['请输入转移概率 P(' num2str(i) ',' num2str(j) '):\n']);
    end
end

% 判断输入矩阵是否满足要求
tag0 = sum(Pcc(:) >= 0);
tag1 = sum(abs((Pcc * ones(s, 1) - 1) < fag));

if tag0 ~= r * s || tag1 ~= r
    error('输入信道转移概率矩阵错误，请重新输入');
end

Pcc(Pcc == 0) = fag;     % 将矩阵中的0置为高次小量

% 算法部分
% 设定信源，迭代求解信道容量
p = ones(1, r) ./ r;      % 初始化信源分布

% 迭代算法（采用矩阵表述）
for k = 1:K
    fai = (ones(s, 1) * p) .* Pcc';
    fai = fai ./ (fai * ones(r, r));   % 计算信源条件下的后向概率
    
    p0 = exp(diag(Pcc * (log(fai)))');
    p = p0 / sum(p0);                  % 计算新的信源分布
    C_new = log(sum(p0));              % 计算信道容量，单位奈特/符号

    % 判断迭代是否终止
    if abs((C_new - C_current)) <= err * C_new
        break;
    else
        C_current = C_new;     % 信道容量结果更新
    end
end

% 判断迭代是否失败
if k == K
    error('迭代计算失败，请重新设置相关参数');
end

% 输出部分
% 输出最大信道容量及对应的最佳信源分布
C = C_new / log(2);       % 单位转换，转换为比特/符号                                               
fprintf('\n');
disp('最佳信源分布P为');
disp(p);
fprintf('信道容量C为%.10f比特/符号\n', C);
