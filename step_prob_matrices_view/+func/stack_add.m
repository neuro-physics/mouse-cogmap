function s = stack_add(s,k)
% adds k to the top of the stack s
% s is a vector with fixed length
% stack_add will shift all elements of s to the right, and add k as the first element in s
    s = circshift(s,1);
    s(1) = k;
end