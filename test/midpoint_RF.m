function [field] = midpoint_RF(Coord, mu, cov, dh, dv, Nsim, ACF)
% 考虑自相关函数影响的边坡可靠度分析, 李典庆

sigma = mu .* cov; 
rou = eye(size(mu, 1));  % 自相关矩阵
L1 = chol(rou);  % L1 == rou
mLem = length(Coord);  % 单元数量

% 检查 dh 和 dv 数组长度，确保 k 不超出范围
if length(dh) == 1
    dh = repmat(dh, size(mu, 1), 1);  % 将 dh 扩展为与 mu 相同的长度
end
if length(dv) == 1
    dv = repmat(dv, size(mu, 1), 1);  % 将 dv 扩展为与 mu 相同的长度
end

% 选择自相关函数类型
for k = 1:size(mu, 1)
    pxy = zeros(mLem);  % 初始化自相关矩阵
    for i = 1:mLem
        for j = 1:mLem
            dx = abs(Coord(i, 1) - Coord(j, 1));
            dy = abs(Coord(i, 2) - Coord(j, 2));
            switch ACF
                case 1  % 指数型自相关函数(SNX)
                    pxy(i, j) = exp(-2 * (dx / dh(k) + dy / dv(k)));
                case 2  % 高斯型自相关函数(SQX)
                    pxy(i, j) = exp(-pi * ((dx / dh(k))^2 + (dy / dv(k))^2));
                case 3  % 二阶自回归型自相关函数(CSX)
                    pxy(i, j) = exp(-4 * (dx / dh(k) + dy / dv(k))) * (1 + 4 * dx / dh(k)) * (1 + 4 * dy / dv(k));
                case 4  % 指数余弦型自相关函数(SMK)
                    pxy(i, j) = exp(-(dx / dh(k) + dy / dv(k))) * cos(dx / dh(k)) * cos(dy / dv(k));
                case 5  % 三角型自相关函数(BIN)
                    if dx < dh(k) && dy < dv(k)
                        pxy(i, j) = (1 - dx / dh(k)) * (1 - dy / dv(k));
                    else
                        pxy(i, j) = 0;
                    end
            end
        end
    end
    PXY(:, :, k) = pxy;  % 存储自相关矩阵
end

% 对每个自相关矩阵进行Cholesky分解
for k = 1:size(mu, 1)
    L2(:, :, k) = chol(PXY(:, :, k))'; 
end

% 拉丁超立方抽样产生独立标准正态随机样本（固定样本种子）
randn('state', 0); rand('state', 0); 
UU = lhsnorm(zeros(size(mu, 1) * mLem, 1), eye(size(mu, 1) * mLem), Nsim)';

% 计算ln-xi的标准差和均值
sLn = sqrt(log(1 + (sigma ./ mu) .^ 2));
mLn = log(mu) - sLn .^ 2 / 2;

% 生成随机场
for imod = 1:Nsim
    U = [];
    for k = 1:size(mu, 1)
        U = [U UU(((k - 1) * mLem + 1):k * mLem, imod)];
    end
    U_ = U * L1;
    H0 = [];
    for k = 1:size(mu, 1)
        H0 = [H0 L2(:, :, k) * U_(:, k)];
        field(:, imod, k) = exp(mLn(k) + sLn(k) * H0(:, k));  % 生成随机场
    end
end

end
