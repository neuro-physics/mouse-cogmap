function P = normalize_cols(P)
    s = sum(P,1); % summing over rows for each column
    s(s==0)=1;
    P = P./s;
end