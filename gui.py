import time
import tkinter as tk
import tkinter.scrolledtext as scrolledtext
from os import system

window_size = (1080, 720)
frame_size = (int(window_size[0] * 0.90), int(window_size[1] - 20))

# create window with size of 1080x720
window = tk.Tk()
window.title("DCC")
window.geometry(f"{window_size[0]}x{window_size[1]}")
window.configure(background='#EF9F9F')


def compile_code():
    # get code from text box
    global code_area
    code = code_area.get("1.0", tk.END)

    # write code to code.cpp file
    with open("code.cpp", "w") as file:
        file.write(code)

    system(f".\dragon_compiler < code.cpp")

    # read output/symbol_table.txt file
    with open("output/symbol_table.txt", "r") as file:
        symbol_table = file.read()

    # display symbol table
    global symbol_table_area
    symbol_table_area.config(state='normal')
    symbol_table_area.delete("1.0", tk.END)
    symbol_table_area.insert("1.0", symbol_table)
    symbol_table_area.config(state='disabled')

    # read output/errors.txt file
    with open("output/errors.txt", "r") as file:
        errors = file.read()

    # display errors
    global errors_area
    errors_area.config(state='normal')
    errors_area.delete("1.0", tk.END)
    errors_area.insert("1.0", errors)
    errors_area.config(state='disabled')

    pass

##### Widgets #####


top_frame = tk.Frame(window, width=frame_size[0], height=frame_size[1],
                     bg="#EF9F9F", borderwidth=5, relief="flat")

code_area = tk.Text(top_frame, width=50, height=28,
                    borderwidth=3, relief="sunken")

symbol_table_area = scrolledtext.ScrolledText(
    top_frame, width=50, height=28, borderwidth=3, relief="sunken", wrap="none")

bottom_frame = tk.Frame(window, width=frame_size[0], height=frame_size[1],
                        bg="#EF9F9F", borderwidth=5, relief="flat")

errors_area = tk.Text(bottom_frame, width=50, height=18,
                      borderwidth=3, relief="sunken")


compile_button = tk.Button(bottom_frame, text="Compile", width=10, height=1, fg='#D61C4E', font=("Helvetica", 14),
                           command=compile_code)

select_file_button = tk.Button(bottom_frame, text="Select file", width=10, height=1, fg='#D61C4E', font=("Helvetica", 14),
                               command=compile_code)


##### Configurations #####

symbol_table_area.configure(state='disabled')
errors_area.configure(state='disabled')

###### Packing Area ######

top_frame.pack()
code_area.pack(side="left", padx=20, pady=30)
symbol_table_area.pack(side="right", padx=20, pady=30)

bottom_frame.pack()
errors_area.pack(side=tk.LEFT, padx=(20, 20), pady=(0, 30))
select_file_button.pack(side=tk.TOP, pady=(0, 20))
compile_button.pack(side=tk.TOP)

# wait for key press
window.mainloop()
