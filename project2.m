%These comands clear all previously saved variables from the workspace and closes all windows previously opened by the program
clear all
close all
clc


%Imports Urban & Highway Driving Schedule and converts into a Matrix to be read by the Simulink Model
urban = importdata("Urban_Dyno_Driving_Schedule.csv");
highway = importdata("Highway_Driving_Schedule.csv");
% Upper torque curve axes
upper_curve = importdata("Torque_Upper.csv");
upper_torque = upper_curve(:,1);
upper_rpm = upper_curve(:,2);
% Lower torque curve axes
lower_curve = importdata("Torque_Lower.csv");
lower_torque = lower_curve(:,1);
lower_rpm = lower_curve(:,2);
% Fuel Map Table
fuelmap = importdata("FuelMapLookup.csv");
% Fuel Map Inputs
fuelmapinputs = importdata("FuelmapInputs.csv");
input_torques = fuelmapinputs(:,1);
input_speed = fuelmapinputs(:,2);
%Speed Ratio Table
sr = importdata("speed_ratio.csv");
%K Factor Table
kfactor = importdata("k_factor.csv");
%Torque Ratio Table
tr = importdata("torque_ratio.csv");



%Asks user for an input on what drive cycle they would like to simulate
prompt = 'What drive cycle would you like to see? (Select 1 for Urban, and 2 for Highway): ' ;
x = input(prompt);


%Model Constants
kp = 2.86; %Proportional error
kd = 0.0; %Derivative error
ki = 0.1; %Integral error
m = (3900*.45359237); %This is the mass of the vehicle in kg
r = (0.339); %This is the average radius of the vehicle wheel in meters
c0 = 0.1; %Dimensionless coefficient of rolling resistance
c1 = 0.02; %Coefficient of rolling resistance while in motion (for car tires on a dry/asphalt road)
cd = 0.3; %Drag coefficient
rho = 1.225; % Air density (kg/m^3)at the sea level
S = 2.3; % Frontal area (m^2)
mT = 375; %Torque in N*m
eff = 0.93; %Efficency
G = 9.73; %Gear Ratio
w_idle = 720; %Engine idle speed rpm
w_max = 6400; %Engine max speed rpm
gas_density = 730; %Density of gasoline in kg/m3
Je = 0.1301; %Engine Inertia in kg*m^2
max_break_torque = 375*12*2*3.36; %Nm
brake_r = 0.339; %m
G_fd = 3.36; %Final Drive Axle Gear Ratio
LCV = 43.4; %Lower Caloric Value

%Gear Ratios
Gear_ratio_1 = 4.58;
Gear_ratio_2 = 2.96;
Gear_ratio_3 = 1.91;
Gear_ratio_4 = 1.45;
Gear_ratio_5 = 1.00;
Gear_ratio_6 = 0.75;

%If the user inputs 1, they selected the urban drive cycle. The following if statement will run
    if x == 1
        %Setting variables to be read by 1D lookup table
        time = urban(:,1);
        vel = urban(:,2);
        sim_time = 1370; %Sets Simulation time
        sim("project2_sim.slx",sim_time); %Runs Simulation


        %Stores simulation outputs
        v_desired = ans.v_desired;
        v_actual = ans.v_actual;
        acceleration = ans.acceleration;
        position = ans.position;
        error = ans.error;
        engine_speed = ans.engine_speed;
        engine_torque = ans.engine_torque;
        transmission_gear_ratio = ans.transmission_gear_ratio;
        brake_torque = ans.brake_torque;
        final_drive_torque = ans.final_drive_torque;
        engine_power = ans.engine_power;
        transmission_output_power = ans.transmission_output_power;
        final_drive_power = ans.final_drive_power;
        brake_power = ans.brake_power;
        drag_loss_power = ans.drag_loss_power;
        vehicle_kinetic_power = ans.vehicle_kinetic_power;
        gallons = ans.gallons;
        total_gallons = max(gallons);
        total_distance = max(position);
        mileage = total_distance/total_gallons;
        answer_prompt = ['The average mpg for the hihgway drive cycle was ',num2str(mileage), ' mpg'];
        disp(answer_prompt);
        fuel_power = ans.fuel_power;

        %Plots outputs on single plot, labels title and axis, and adds a legend
        tiledlayout(3,3)
        nexttile
        hold on
        plot(v_desired,'g-')
        plot(v_actual,'b-')
        plot(v_desired + 3, 'r-' )
        plot(v_desired - 3, 'r-')
        hold off
        title('EPA Cycle');
        xlabel('Time (s)')
        ylabel('Velocity (mph)')
        legend('V Desired','V Actual','Upper Limit & Lower Limit');


        %Plots for project 2
%         ax2 = nexttile;
%         plot(error, 'r-');
%         title('Error v. Time (s)');
%         xlabel('Time (s)');
%         ylabel('Velocity Error (mph)');


%         ax3 = nexttile;
%         plot(acceleration, 'g-');
%         title(ax3, 'acceleration v. time');
%         xlabel('Time (s)');
%         ylabel('acceleration (ft/s^2)');
%     
% 
%         ax4 = nexttile;
%         plot(position, 'b-');
%         title(ax4, 'position v. time');
%         xlabel('Time (s)');
%         ylabel('Position (mi)');

        ax3 = nexttile;
        plot(transmission_gear_ratio, 'm-');
        title(ax3, 'Gear Ratio v. Time (s)');
        xlabel('Time (s)');
        ylabel('Gear Ratio');

        ax4 = nexttile;
        plot(engine_speed, 'k-');
        title(ax4, 'Engine Speed (RPM) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Engine Speed (RPM)');

        ax4 = nexttile;
        plot(engine_torque, 'g-');
        title(ax4, 'Engine Torque (Nm) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Engine Torque (Nm)');

        ax5 = nexttile;
        hold on
        plot(brake_torque, 'b-');
        plot(final_drive_torque, 'c-');
        hold off
        title(ax5, 'Torque (Nm) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Torque (Nm)');
        legend('Brake Torque','Final Drive Torque');

        ax6 = nexttile;
        hold on
        plot(fuel_power, 'y-');
        plot(engine_power, 'r-');
        plot(transmission_output_power, 'g-');
        plot(final_drive_power, 'b-');
        plot(brake_power, 'c-');
        plot(drag_loss_power, 'm-');
        plot(vehicle_kinetic_power, 'k-');
        hold off
        title(ax6, 'Power (W) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Power (W)');
        legend('Fuel Power','Engine Power','Transmission Output Power','Final Drive Power','Brake Power','Drag Loss Power','Vehicle Kinetic Power');
    end

%If the user inputs 2 they have selected the highway model. The following if statement will run    
    if x == 2


        %Sets variables to be used by 1D look up table
        time = highway(:,1);
        vel = highway(:,2);
        sim_time = 766; %Sets simulation time
        sim("project2_sim.slx", sim_time); %Runs simulation


        %Stores simulation outputs
        v_desired = ans.v_desired;
        v_actual = ans.v_actual;
        acceleration = ans.acceleration;
        position = ans.position;
        error = ans.error;
        engine_speed = ans.engine_speed;
        engine_torque = ans.engine_torque;
        transmission_gear_ratio = ans.transmission_gear_ratio;
        brake_torque = ans.brake_torque;
        final_drive_torque = ans.final_drive_torque;
        engine_power = ans.engine_power;
        transmission_output_power = ans.transmission_output_power;
        final_drive_power = ans.final_drive_power;
        brake_power = ans.brake_power;
        drag_loss_power = ans.drag_loss_power;
        vehicle_kinetic_power = ans.vehicle_kinetic_power;
        gallons = ans.gallons;
        total_gallons = max(gallons);
        total_distance = max(position);
        mileage = total_distance/total_gallons;
        answer_prompt = ['The average mpg for the hihgway drive cycle was ',num2str(mileage), ' mpg'];
        disp(answer_prompt);
        fuel_power = ans.fuel_power;
        %Plots outputs on single plot, labels title and axis, and adds a legend
        tiledlayout(3,3)
        nexttile
        hold on
        plot(v_desired,'g-')
        plot(v_actual,'b-')
        plot(v_desired + 3, 'r-' )
        plot(v_desired - 3, 'r-')
        hold off
        title('EPA Cycle');
        xlabel('Time (s)')
        ylabel('Velocity (mph)')
        legend('V Desired','V Actual','Upper Limit & Lower Limit');


        %Plots for project 2
%         ax2 = nexttile;
%         plot(error, 'r-');
%         title('Error v. Time (s)');
%         xlabel('Time (s)');
%         ylabel('Velocity Error (mph)');


%         ax3 = nexttile;
%         plot(acceleration, 'g-');
%         title(ax3, 'acceleration v. time');
%         xlabel('Time (s)');
%         ylabel('acceleration (ft/s^2)');
%     
% 
%         ax4 = nexttile;
%         plot(position, 'b-');
%         title(ax4, 'position v. time');
%         xlabel('Time (s)');
%         ylabel('Position (mi)');

        ax3 = nexttile;
        plot(transmission_gear_ratio, 'm-');
        title(ax3, 'Gear Ratio v. Time (s)');
        xlabel('Time (s)');
        ylabel('Gear Ratio');

        ax4 = nexttile;
        plot(engine_speed, 'k-');
        title(ax4, 'Engine Speed (RPM) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Engine Speed (RPM)');

        ax4 = nexttile;
        plot(engine_torque, 'g-');
        title(ax4, 'Engine Torque (Nm) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Engine Torque (Nm)');

        ax5 = nexttile;
        hold on
        plot(brake_torque, 'b-');
        plot(final_drive_torque, 'c-');
        hold off
        title(ax5, 'Torque (Nm) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Torque (Nm)');
        legend('Brake Torque','Final Drive Torque');

        ax6 = nexttile;
        hold on
        plot(fuel_power,'y-');
        plot(engine_power, 'r-');
        plot(transmission_output_power, 'g-');
        plot(final_drive_power, 'b-');
        plot(brake_power, 'c-');
        plot(drag_loss_power, 'm-');
        plot(vehicle_kinetic_power, 'k-');
        hold off
        title(ax6, 'Power (W) v. Time (s)');
        xlabel('Time (s)');
        ylabel('Power (W)');
        legend('Fuel Power','Engine Power','Transmission Output Power','Final Drive Power','Brake Power','Drag Loss Power','Vehicle Kinetic Power');
    end





