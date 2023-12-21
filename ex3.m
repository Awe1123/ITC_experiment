clear;
clc;
% 用户输入符号概率
p = input('请输入离散信源概率分布：\n');

% 检查输入概率和是否为1
if abs(sum(p) - 1) > eps
    error('输入概率和不为1，请重新输入。');
end

N = length(p);

symbols = cell(1,N);
for i=1:N         % i表示第几个符号
    symbols{i} = ['a',num2str(i)];
end
symbols1 = ["a1", "a2", "a3", "a4", "a5", "a6", "a7" ];

[dict,L_ave] = huffmandict(symbols,p);
[symbols , probabilities , Code , L_average ,Code_L_error, Hx , Code_efficiency] = ThreeHuffman_Code(symbols1,p);

dict = dict.';
H = sum(-p.*log2(p)); % 计算信源信息熵
yita = H/L_ave;       % 计算编码效率

CODE = strings(1,N); % 初始化对应码字
for i=1:N            % i表示第几个符号
    CODE(i) = num2str(dict{2,i});
end

% 输出二进制霍夫曼编码码字、平均码长和编码效率
fprintf('\n运行结果:\n');
disp('信源符号：');disp(dict(1,1:N));
disp(['对应概率：',num2str(p)]);
fprintf('\n1.二进制霍夫曼编码:\n');
disp('对应码字：');disp(CODE);
disp(['平均码长：',num2str(L_ave)]);
disp(['编码效率：',num2str(yita)]);

fprintf('\n2.三进制霍夫曼编码:\n');
disp('对应码字：');disp(Code);
disp(['平均码长：',num2str(L_average)]);
disp(['编码效率：',num2str(Code_efficiency)]);
 
function [symbols , probabilities , Code , L_average ,Code_L_error, Hx , Code_efficiency] = ThreeHuffman_Code(symbols,probabilities)
%{
      三元霍夫曼编码函数
%}
% 输入:
% symbols - 一个行向量，其中包含要编码的符号
% probabilities - 一个与符号相同大小的向量，表示每个符号出现的概率
% 输出:
% symbols - 一个字符串数组，输入的符号symbol按照出现概率升序输出
% probabilities - 每个符号对应升序输出概率
% Code - 元细胞数组，与symbols、probabilities对应的码字
% L_average - 平均码长
% Code_L_error- 码长方差
% Hx - 信息熵
% Code_efficiency - 编码效率
 
 
%
N = length(probabilities);
 
%建立一个元细胞数组
leaves = cell(N,1);
%先进行排序，也可以在建立霍夫曼树是再排序，这里是现在这里排序
[probabilities,index] = sort(probabilities,'ascend');
symbols = symbols(index);%符号也跟着概率排序，避免丢失不对应
 
%使用结构体来存储建立的霍夫曼树
 for i = 1 : N
     leaves{i} = struct('symbol', symbols(i), 'probability', probabilities(i), 'code', '');
 end
%建立霍夫曼二叉树
  while length(leaves) > 1
      %找最小概率为左子树
      left_child = leaves{1};
      %第二小概率为中子树
      middle_child = leaves{2};
      %第三小概率为右子树
      right_child = leaves{3};
      %左中右子树概率和为父节点概率
      parent_prob = left_child.probability + middle_child.probability + right_child.probability;
      % 将父节点插入list中
      parent = struct('symbol', [],'probability',parent_prob, 'code', '');
      %同时相应的左右子树树干给命名为'0'，'1'
      left_child.code = '0';
      middle_child.code = '1';
      right_child.code = '2';
      parent.left = left_child;
      parent.middle = middle_child;
      parent.right = right_child;
      % 将父节点插入结构体（树）中
      leaves = [ {parent} ; leaves(4:end) ];
      %建立一个空数组，存储最新的树叶子（节点）概率，方便再次对结构排序
      leave = [];
      for i = 1:length(leaves)
          a = leaves{i}.probability;
          leave = [leave,a];
      end
      %索引排序，找到最小的两片树叶
      [~,index] = sort(leave,'ascend');
          leaves = leaves(index);
  end
 
    % 递归计算编码
root = leaves{1};
% dict - 一个结构体，包含每个符号的编码
dict = struct();
stack = {};
%递推的树干
stack{end+1} = root;
while ~isempty(stack)
    node = stack{end};
    %将树干清空，方便递推存入新的树干
     stack(end) = [];
     %判断是否已经到达树叶，输出码字
     if isfield(node,'left') == 0 && isfield(node,'middle') == 0 && isfield(node,'right') == 0
        dict.(node.symbol) = node.code;
     end
     %处理左子树，将它加入路径中
     if isfield(node,'left')==1
         node.left.code = strcat(node.code, node.left.code);
         stack{end+1} = node.left;
     end
 
     if isfield(node,'middle')==1
         node.middle.code = strcat(node.code, node.middle.code);
         stack{end+1} = node.middle;
     end
 
     %处理右子树，将它加入路径中
     if isfield(node,'right')==1
         node.right.code = strcat(node.code, node.right.code);
         stack{end+1 } = node.right;
     end
     
end
 
% 构造编码矩阵
Code = "";
for i = N:-1:1
    Code{i} = dict.(symbols(i));
end
 
%计算平均码长
Code_length = [];
for i = 1:N
    Code_length(i) = length(char(Code(i)));
end
L_average = sum(Code_length.*probabilities);
 
Code_L_error = 0;
for i = 1:N
   Code_L_error = Code_L_error + (Code_length(i)-L_average) * (Code_length(i)-L_average).*probabilities(i);
end
 
%计算信息熵
Hx = sum(-probabilities.*log2(probabilities));
%计算编码效率
Code_efficiency = Hx/(L_average * log2(3));

end
 