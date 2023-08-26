function [] = Prediction_visualization(target,RC1_prediction,RC2_prediction,display_names,x_label,y_label,graph_title,time_sequence_begin,time_sequence_end)
tar = target(time_sequence_begin:time_sequence_end);
RC1_p = RC1_prediction(time_sequence_begin:time_sequence_end);
RC2_p = RC2_prediction(time_sequence_begin:time_sequence_end);
x = time_sequence_begin:time_sequence_end;
figure;
plot(x,tar,'r-o', 'DisplayName', display_names(1));
hold on;
plot(x,RC1_p,'b-*', 'DisplayName', display_names(2));
hold on;
plot(x,RC2_p,'c-^', 'DisplayName', display_names(3));
hold off;
legend();
title(graph_title);
xlabel(x_label);
ylabel(y_label);
end