#common options
set disassemble-next-line on
set confirm off

#custom commands

python
import gdb

class Offsets(gdb.Command):
    def __init__(self):
        super (Offsets, self).__init__ ('offsetsof', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)
        if len(argv) != 1:
            raise gdb.GdbError('offsets-of takes exactly 1 argument.')

        stype = gdb.lookup_type(argv[0])

        print (argv[0], '{')
        for field in stype.fields():
            print ('    %s => %d' % (field.name, field.bitpos//8))
        print ('}')

Offsets()
end






python
import gdb
import sdl2.ext as sdl

class RenderMem(gdb.Command):
    def __init__(self):
        super (RenderMem, self).__init__ ('rendermem', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        if len(argv) != 3:
            raise gdb.GdbError('rendermem takes exactly 3 args.')

        #addr = gdb.parse_and_eval(argv[0] +'[0][0]')
        base_addr = argv[0]
        w = int( argv[1] )
        h = int( argv[2] )

        sdl.init()

        window = sdl.Window("Rendermem",size = (w,h))

        window.show()

        surface = window.get_surface()

        for y in range(0,h):
            for x in range(0,w):
                val = int(gdb.parse_and_eval(base_addr + '[' + str(x) + '][' + str(y) + ']'))
                color = sdl.Color(255,255,255)
                sdl.fill(surface,color,(x,y,w,h))


        input('')

        sdl.quit()

RenderMem()


end


python
import gdb

class PrintArr(gdb.Command):
    def __init__(self):
        super (PrintArr, self).__init__ ('printarr', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        if len(argv) != 3:
            raise gdb.GdbError('printarr takes exactly 3 args.')

        arr = argv[0]
        el = argv[1]
        count = int(argv[2])

        for i in range(0,count):
            val = gdb.parse_and_eval(arr + '[' + str(i) + '].' + el)
            print(val)


PrintArr()

 end


python
import gdb
import pptree
import sys
import webbrowser
import uuid


def buildtreeAssimp(node,parent,bones):

    name = node['name'].string()
    count = node['children_count']

    tree = pptree.Node(name,parent)

    for i in range(0,count):
        index_array = node['childrenindex_array']
        index = index_array[i]
        n = gdb.parse_and_eval(bones + '[' + str(index) +']')

        buildtreeAssimp(n,tree,bones)

    return tree

def buildtreeBFS(arr):
    queue = []
    count = int(gdb.parse_and_eval(arr + '.count'))

    root = None

    for i in range(0,count):
        e = gdb.parse_and_eval(arr + '[' + str(i) +']')
        name = e['name'].string()
        children_count = e['children_count']

        parent = None

        if len(queue) > 0:
            parent = queue.pop(0)

        node = pptree.Node(name,parent)

        if parent == None:
            root = node

        for j in range(0,children_count):
            queue.append(node)

    return root


def createtree(argv):

    if len(argv) < 2:
        raise gdb.GdbError('printtree takes at least 3 args')

    tree = None

    if argv[0] == 'assimp':
        root = gdb.parse_and_eval(argv[1] + '[0]')
        bones = argv[1]
        tree = buildtreeAssimp(root,None,bones)

    if argv[0] == 'bfs':
        arr = argv[1]
        tree = buildtreeBFS(arr)

    return tree

class PrintTree(gdb.Command):
    def __init__(self):
        super (PrintTree, self).__init__ ('printtree', gdb.COMMAND_DATA)


    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        if len(argv) < 2:
            raise gdb.GdbError('printtree takes at least 3 args')

        tree = createtree(argv)

        pptree.print_tree(tree, horizontal = True)

PrintTree()


class DumpTree(gdb.Command):
    def __init__(self):
        super (DumpTree, self).__init__ ('dumptree', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        tree = createtree(argv)
        filename = str(uuid.uuid4()) + '.txt'

        sys.stdout = open(filename,'w')
        pptree.print_tree(tree, horizontal = True)
        sys.stdout.close()

        webbrowser.open(filename)

DumpTree()

end



python
import gdb
import termplotlib as tpl
import sys



class PlotArr(gdb.Command):
    def __init__(self):
        super (PlotArr, self).__init__ ('plotarr', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)
        if len(argv) < 2:
            raise gdb.GdbError('plotarr takes exactly 2 argument.')


        arr = argv[0]
        count = int(argv[1])
        s = 1

        if len(argv) >= 3:
            if argv[2].isnumeric():
                s = int(argv[2])

        x = range(0,count)
        y = list()

        for i in x:
            val = gdb.parse_and_eval(arr + '[' + str(i * s) + ']')
            val = val.cast(gdb.lookup_type('float'))
            y.append(float(val))

        fig = tpl.figure()
        fig.plot(x,y,label = 'data', width = 50, height = 15)

        fig.show()


PlotArr()

end
