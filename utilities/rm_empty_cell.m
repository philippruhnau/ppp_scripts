function out = rm_empty_cell(in)

% function [out] = RM_EMPTY_CELL(in)
% removes empty cells from a cell array



keep_idx = cellfun(@isempty,in);
out = in(~keep_idx);
