
clc; clear
%% 参数设置
numberofINP = 500;
maxlineINP = 100000; % 数值要大于最大行数
materialline = [11245 19974 7]; % 第一个材料名所在行，最后一个材料名所在行, 每种材料占行数

%% 载入数据
inpfile = importdata('Job-0.inp', ',', maxlineINP);
param1 = importdata('param1.txt');
param2 = importdata('param2.txt');
param3 = importdata('param3.txt');
param4 = importdata('param4.txt');

%% 生成inp
warning('off')
for i = 1:(numberofINP-1)
    writteinp(i, materialline, param1, param2, param3, param4, inpfile)
end

function [] = writteinp(i, materialline, param1, param2, param3, param4, inpfile)
    name_INP = {'Job-', num2str(i), '.inp'};
    INPname = [name_INP{1} name_INP{2} name_INP{3}];
    
    %% 修改材料参数 
    line = 1;
    for j = materialline(1):materialline(3):(materialline(2))
        % 获取弹性模量和泊松比
        elasticModulus = param1(line, i + 1);
        poissonRatio = param2(line, i + 1);
        
        % 控制泊松比小于0.5
        if poissonRatio >= 0.5
            poissonRatio = 0.49;  % 修正为0.49，避免超过0.5
        end
        
        value = { num2str(elasticModulus), ', ', num2str(poissonRatio)};  % 弹性模量和泊松比
        assignmaterial = [value{1} value{2} value{3}];
        inpfile(j + 2, 1) = cellstr(assignmaterial);
        
        % 更新其他参数
        value = {' ', num2str(param4(line, i + 1)), ',', '0.'}; % phi
        assignmaterial = [value{1} value{2} value{3} value{4}];
        inpfile(j + 4, 1) = cellstr(assignmaterial);
        
        value = {' ', num2str(param3(line, i + 1)), ',', '0.'}; % c
        assignmaterial = [value{1} value{2} value{3} value{4}];
        inpfile(j + 6, 1) = cellstr(assignmaterial);
        
        line = line + 1;
    end
    
    %% 生成空白inp
    save(INPname, 'inpfile', '-ascii')
    
    %% 写入inp
    file = fopen(INPname, 'r+');
    for z = 1:size(inpfile, 1)
        fprintf(file, inpfile{z, 1});
        fprintf(file, '\n');
    end
    fclose(file);
end
