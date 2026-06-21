# -*- coding:utf-8 -*-
from abaqus import *
from abaqusConstants import *
from caeModules import *
from driverUtils  import executeOnCaeStartup
import numpy
from numpy import *


elelist = numpy.loadtxt('elelist.txt')
para1 = numpy.loadtxt('param1.txt')
para2 = numpy.loadtxt('param2.txt')
para3 = numpy.loadtxt('param3.txt')
para4 = numpy.loadtxt('param4.txt')

numinp=1
mypart='Part-1'
Modelname='Model-1'
mymdb=mdb
myele=mymdb.models[Modelname].parts[mypart].elements
p=mdb.models[Modelname].parts[mypart]
myele=p.elements
elenum=len(myele)
num=0
for inp in range(numinp):
    for ele in elelist:
        ele=int(ele)
        mdb.models[Modelname].Material(name='TempM-'+str(ele))
        mdb.models[Modelname].materials['TempM-'+str(ele)].Elastic(table=((para1[num][inp],para2[num][inp]),))
        mdb.models[Modelname].materials['TempM-'+str(ele)].MohrCoulombPlasticity(table=((
            para4[num][inp], 0.0), ))
        mdb.models[Modelname].materials['TempM-'+str(ele)].mohrCoulombPlasticity.MohrCoulombHardening(
            table=((para3[num][inp], 0.0), ))
        mdb.models[Modelname].materials['TempM-'+str(ele)].mohrCoulombPlasticity.TensionCutOff(
            temperatureDependency=OFF, dependencies=0, table=((0.0, 0.0), ))
        mdb.models[Modelname].HomogeneousSolidSection(name='TempS-'+str(ele),material='TempM-'+str(ele),thickness=None)
        p.Set(elements=myele[(ele-1):(ele)],name='Tempset-'+str(ele))
        region=p.sets['Tempset-'+str(ele)]
        p.SectionAssignment(region=region,sectionName='TempS-'+str(ele),offset=0.0,
            offsetType=MIDDLE_SURFACE,offsetField='',
            thicknessAssignment=FROM_SECTION)
        num=num+1
    # inp generate
    mdb.Job(name='Job-'+str(inp), model=Modelname, description='', type=ANALYSIS, 
        atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
        memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
        explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
        modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, userSubroutine='', 
        scratch='', resultsFormat=ODB, multiprocessingMode=DEFAULT, numCpus=1, 
        numGPUs=0)
    mdb.jobs['Job-'+str(inp)].writeInput(consistencyChecking=OFF)

