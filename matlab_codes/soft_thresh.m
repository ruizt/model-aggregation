function out = soft_thresh(x, y)
out = sign(x).*(abs(x) - y).*(abs(x) > y); 
