function [ Ad,Bd,Cd ] = matrixLongLatLinear( initial_x, initial_y, initial_theta, s_k, velocity_guess, omega_guess, path_speed_guess, coff_arc_x, coff_arc_y, arc_param, delta_t, n_steps )
%MATRIXLONGLATLINEAR Summary of this function goes here
%   Detailed explanation goes here

[ x_guess, y_guess, theta_guess ] = calcGuessStates( initial_x, initial_y, initial_theta, velocity_guess, omega_guess, delta_t );
s_guess = s_k + cumsum(path_speed_guess*delta_t);
[ x_path_guess, y_path_guess, theta_path_guess, index_guess] = progressPath(s_guess, s_k, coff_arc_x, coff_arc_y, arc_param );

const_con =  sin(theta_path_guess)*(x_guess-x_path_guess) - cos(theta_path_guess)*(y_guess-y_path_guess);
const_lag = -cos(theta_path_guess)*(x_guess-x_path_guess) - sin(theta_path_guess)*(y_guess-y_path_guess);

% xk sin(o(p))

coef_x = [];
coef_y = [];
utmatrix = triu(ones(n_steps,n_steps));

for m = 1:n_steps
    temp_cos = cos(theta_guess(1:m,1))*delta_t;
    temp_sin = sin(theta_guess(1:m,1))*delta_t;
    x_v_coef = [temp_cos;zeros(n_steps-m,1)];
    y_v_coef = [temp_sin;zeros(n_steps-m,1)];
    temp_u = utmatrix(1:m,1:m);
    x_o_coef = [temp_u*(-temp_sin)*delta_t;zeros(n_steps-m,1)];
    y_o_coef = [temp_u*(+temp_cos)*delta_t;zeros(n_steps-m,1)];
    coef_x = [ coef_x,[ x_v_coef; x_o_coef ] ];
    coef_y = [ coef_y,[ y_v_coef; y_o_coef ] ];
end

coef_x_p = [];
coef_y_p = [];

for m = 1:n_steps
    temp_index = index_guess(m,1);
    s_pick = arc_param(temp_index,1);
    del_x = 3*coff_arc_x(temp_index,1)*(s_guess(m,1)-s_pick)^2 + ...
            2*coff_arc_x(temp_index,2)*(s_guess(m,1)-s_pick) + ...
            coff_arc_x(temp_index,3);
    del_y = 3*coff_arc_y(temp_index,1)*(s_guess(m,1)-s_pick)^2 + ...
            2*coff_arc_y(temp_index,2)*(s_guess(m,1)-s_pick) + ...
            coff_arc_y(temp_index,3);
    coef_x_p = [coef_x_p,[del_x*delta_t*ones(m,1);zeros(n_steps-m,1)]];
    coef_y_p = [coef_y_p,[del_y*delta_t*ones(m,1);zeros(n_steps-m,1)]];
    
end







A = zeros(3*n_steps,3*n_steps);
B = zeros(3*n_steps,1);
C = 0;

for m = 1:n_steps
    con_made = sin(theta_path_guess(m,1))*coef_x(:,m) - ...
                cos(theta_path_guess(m,1))*coef_y(:,m);
    lag_made = -cos(theta_path_guess(m,1))*coef_x(:,m) - ...
                sin(theta_path_guess(m,1))*coef_y(:,m);
    con_cons = sin(theta_path_guess(m,1))*(cons_x(1,m)-x_path_guess(m,1)) - ...
                cos(theta_path_guess(m,1))*(cons_y(1,m)-y_path_guess(m,1));
    lag_cons = -cos(theta_path_guess(m,1))*(cons_x(1,m)-x_path_guess(m,1)) - ...
                sin(theta_path_guess(m,1))*(cons_y(1,m)-y_path_guess(m,1));
    A = A + con_weight*(con_made*con_made') + lag_weight*(lag_made*lag_made');
    B = B + 2*con_weight*con_made*con_cons + 2*lag_made*lag_cons;
    C = C + con_weight*con_cons*con_cons + lag_weight*lag_cons*lag_cons;

end

end

