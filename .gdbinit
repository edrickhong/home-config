#environment var to force vulkan driver

#python
#import os
#gdb.execute('set environment VK_ICD_FILENAMES = ' + os.environ['HOME'] + '/.local/share/vulkan/icd.d/amd_icd64.json')
#gdb.execute('set environment LD_LIBRARY_PATH = ' + os.environ['HOME'] + '/debug/')
#end


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
