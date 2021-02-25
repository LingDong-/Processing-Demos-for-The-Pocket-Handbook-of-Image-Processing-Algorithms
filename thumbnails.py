from glob import glob
files = sorted(glob("*/preview.png"))
out = "| | |\n|---|---|\n|"
col = 2
l0 = ""
l1 = ""
for i in range(0,len(files)):

	proj = files[i].split("/")[0]
	l0 += " [![](./"+files[i]+")](./"+proj+") |"
	l1 += " ["+proj+"](./"+proj+") |"

	if ((i+1) % col == 0):
		out += l0 + "\n|" + l1 + "\n|"
		l0 = ""
		l1 = ""

if (len(l0)):
	out += l0 + "\n|" + l1 + "\n"
	
print(out)