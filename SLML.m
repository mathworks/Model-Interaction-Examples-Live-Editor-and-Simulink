classdef SLML
    %SLMLlib a library of programmatic functions to make it easier to
    %interact with simulink from matlab
    properties (Constant)
        simulinkOutput = 'out';
        SimulinkOutputDT = 'Simulink.SimulationOutput';
        NodeDT = 'simscape.logging.Node';
    end
    
    methods (Static)
        
        function [t,data,name] = UnpackSig(signal)
            ts = signal.Values;
            [t,data,name] = SLML.UnpackTS(ts);
        end
        
        function [t,data,name] = UnpackTS(ts)
            t = ts.Time;
            data = ts.Data;
            name = ts.Name;
        end
        
        function OpenDataInspector
            Simulink.sdi.view;
        end
        
        function OpenSimscapeExplorer(simlog)
            % SLML.OpenSimscapeExplorer(simlog)
            % SLML.OpenSimscapeExplorer(out)
            % will open the simscapeexplorer
            % if simlog isn't provided, it grab the 1st
            % simulation output in the workspace
            haveOutFlag = 0;
            if nargin == 1
                if strcmp(class(simlog),SLML.NodeDT)
                    sscexplore(simlog)
                    return
                elseif strcmp(class(simlog),SLML.SimulinkOutputDT)
                    out = simlog;
                    haveOutFlag = 1;                    
                else
                    throw(['Incorrect Data Type: Needs ', SLML.SimulinkOutputDT,' or ', SLML.NodeDT])
                end
            end
           
            if ~haveOutFlag
                vars = MLDT.GetClassVariablesBase(SLML.SimulinkOutputDT);
                if length(vars) < 1
                    throw(['No usable variables found'])
                end
                var = vars{1};
                out = evalin('base',[var]);
            end
            vars = MLDT.GetSimulinkOutClass(out,SLML.NodeDT);
            name = vars;
%                 name = SLML.GetSimscapeLogName; 
%                 name = ['out.' name];
            simlog = getfield(out,name);
            assignin('base','simlog',simlog)
            evalin('base','sscexplore(simlog)')
%             sscexplore(simlog)
                        
        end            
        
        function [file,imData] = GenerateModelImage(model)
            load_system(model);
            file = [model,'.jpg'];
            print(['-s',model],'-djpeg',file)
            imData=imread([model,'.jpg']);
            close_system(model);
        end  
        
        function [SimConfigData] = GetSimulationConfigData(sys)
            % SLML.GetSimulationConfigData(sys)
            % will get a list from get_param and show some of data
            % leaving sys empty will default to gcs()
            if nargin == 0
                sys = gcs;
            end
            h = get_param(sys,'ObjectParameters');
            SimConfigData = fieldnames(h);
            n = length(SimConfigData);
            
            % there can be write only fields where tihs doesn't work
            for i = 1:n   
                try
                    SimConfigData{i,2} = get_param(sys,SimConfigData{i});
                catch
                end
            end
        end
        
        function [SimConfigData] = GetBlockParams(block)
            % SLML.GetBlockParams(block)
            % will get a list from get_param and show some of data
            % leaving block empty will default to gcb()
            if nargin == 0
                block = gcb;
            end
            h = get_param(block,'ObjectParameters');
            SimConfigData = fieldnames(h);
            n = length(SimConfigData);
            
            % there can be write only fields where this doesn't work
            for i = 1:n   
                try
                    SimConfigData{i,2} = get_param(sys,SimConfigData{i});
                catch
                end
            end
        end
        
        function SetSimscapeLog(sys,setting)
            % SLML.SetSimscapeLog(sys,setting)
            % Setting values
            % 0 = none
            % 1 = all
            % 2 = local
            % leaving sys empty will default to gcs()
            if nargin == 1
                setting = sys;
                sys = gcs;
            end
            if setting == 1
                set_param(sys,'SimscapeLogType','all')
            elseif setting == 2
                set_param(sys,'SimscapeLogType','local')
            else
                set_param(sys,'SimscapeLogType','none')
            end
        end
        
    end
    
    methods(Static= true, Access = protected)
        function [name] = GetSimscapeLogName(sys)
            % SLML.GetSimscape
            % leaving sys empty will default to gcs()
            if nargin == 0
                sys = gcs;
            end  
            name = get_param(sys,'SimscapeLogName');
        end 
    end
    
end

