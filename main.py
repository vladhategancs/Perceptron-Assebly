import numpy as np
import matplotlib.pyplot as plt
import time
import subprocess

weights = []
above_x = []
above_y = []

below_x = []
below_y = []

with open('data.txt', 'w') as file:
    cntA = 0
    cntB = 0
    while cntA < 100 and cntB < 100:
        x = np.random.randint(-100, 100)
        y = np.random.randint(-100, 100)

        if y + x > 15 and cntA < 100:
            file.write(str(x) + ' ' + str(y) + ' ' + '1\n')
            above_x.append(x)
            above_y.append(y)
            plt.scatter(above_x, above_y, color='red')
            cntA = cntA + 1

        if y + x < -15 and cntB < 100:
            file.write(str(x) + ' ' + str(y) + ' ' + '-1\n')
            below_x.append(x)
            below_y.append(y)
            plt.scatter(below_x, below_y, color='blue')
            cntB = cntB + 1

xx = np.linspace(-100, 100)

subprocess.call('main.exe')
time.sleep(1)

with open('weights.txt', 'r') as file:
    cnt = 0
    while cnt < 1500:
        line = file.readline()
        weights = [float(field) for field in line.split()]

        a = -weights[0] / weights[1]
        yy = a*xx - weights[2]/weights[1]

        plt.plot(xx, yy, 'k-')
        plt.scatter(above_x, above_y, color='red')
        plt.scatter(below_x, below_y, color='blue')
        plt.pause(0.01)
        plt.clf()

        cnt = cnt + 1
        print(cnt)


plt.plot(xx, yy, 'k-')
plt.scatter(above_x, above_y, color='red')
plt.scatter(below_x, below_y, color='blue')
plt.show()