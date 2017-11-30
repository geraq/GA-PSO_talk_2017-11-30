using PyPlot
using PyCall
@pyimport numpy as np

y = -0.5:0.1:3
#y = -0.5:0.1:3
x = -1.5:0.1:2
(X,Y) = np.meshgrid(x,y)
xv = vec(X)
yv = vec(Y)
g = [xv yv]
rosen(x,y) = (1-x)^2 + 100(y -x^2)^2
z = mapslices(p -> rosen(p[1], p[2]), g, 2)

fig = figure()
ax = fig[:add_subplot](111, projection="3d")
ax[:plot_surface](X, Y, reshape(z, length(x), length(y)), cmap="Spectral")
#ax[:plot_surface](X, Y, reshape(z, length(x), length(y)), cmap="terrain")

#ax[:clear]()
