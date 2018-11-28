close all
figure(1)
load NC
semilogy(EbN0dB,ber);

xlim([-2 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)
legend({'TEB (non cod\''e)'}, 'Interpreter', 'latex', 'FontSize',14);