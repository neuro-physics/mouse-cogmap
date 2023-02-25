function d = mahalsqrt(C,P)
    if ndims(C) == 3
        n = size(C,2);
        d = zeros(1,n);
        for i = 1:n
            d(i) = mahal_internal(squeeze(C(:,i,:)),nanmean(squeeze(P(:,i,:)),1));
        end
    else
        d = mahal_internal(C,P);
    end
end

function d = mahal_internal(C,P)
    [C,P] = eliminateZeroCol(C,nanmean(P,1));
    [C,P] = eliminateNaNRows(C,P);
    d = 0;
    if ~isempty(C) && ~isempty(P)
        d = sqrt(mahal(P,C));
    end
end

function [C,P] = eliminateZeroCol(C,P)
    k = ~all(C == 0,1);
    P = P(:,k);
    C = C(:,k);
end

function [C,P] = eliminateNaNRows(C,P)
    C = C(~any(isnan(C),2),:);
    P = P(~any(isnan(P),2),:);
end