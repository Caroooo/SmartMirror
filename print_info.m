function print_info(person_name, hb, bps, bpd, rr, fps)
clc
fprintf('Person: %20s\n', person_name); 
fprintf('Heartbeat: %3s bps\n', num2str(hb));
fprintf('Blood Pressure: %3s /%3s mmHg\n', num2str(bps), num2str(bpd));
fprintf('Respiration Rate: %3s rcpm\n', num2str(rr));
fprintf('Frame Rate: %2.2f fps\n', fps);