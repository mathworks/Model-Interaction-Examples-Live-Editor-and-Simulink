classdef MLDT
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        
    end
    
    methods(Static)
        function [list] = GetClassVariablesBase(class)
            s = evalin('base','whos'); 
            % find the objects with the type 'ClassName' from the workspace:
            matches= strcmp({s.class}, class);
            list = {s(matches).name};
        end
        
        function [list] = GetSimulinkOutClass(struct,searchClass)
            % MLDT.GetClassVariablesStruct(struct,class)
            % Goes through one layer of struct to find classes
            s = struct.who;
            list = [];
            for i = 1:length(s)
                var = getfield(struct,s{i});
                if strcmp(searchClass,class(var))
                    list = [s{i} list];
                end
            end                
        end
        
    end
end

