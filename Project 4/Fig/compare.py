file = open('light.txt').read()
light = [i.strip for i in file.split('\n')]
file = open('dark.txt').read()
dark = [i.strip for i in file.split('\n')]

for i in range(len(dark)):
    if dark[i] != light[i]:
        print(i)
    