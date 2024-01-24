import pandas as pd
import os 
import numpy as np

path = "C:\\Users\\Juan\\Desktop\\Neuronal Excitability Lab\\ImageJ processing\\Microglia dynamics\\Analysis"
# Timestack multimeasure results
timestack_names = []
timestack_paths = []
extension = ".csv"

# Cumulative multimeasure results
cumulative_paths = []

# Fods multimeasure results
fod_paths = []
    
for root, dirs, files in os.walk(path):
    for name in files:
        if "timestack" in name and name.endswith(extension):
            timestack_paths.append(os.path.join(root,name))
            name = name.replace(extension, "")
            timestack_names.append(name)
        
        if "cumulative" in name and name.endswith(extension):
            cumulative_paths.append(os.path.join(root,name))
        
        if "first" in name and name.endswith(extension):
            fod_paths.append(os.path.join(root,name))
        
    
print(timestack_names, "\n")
print(timestack_paths, "\n")
print(cumulative_paths, "\n")
print(fod_paths, "\n")

timestack_names.sort()
timestack_paths.sort()
cumulative_paths.sort()
fod_paths.sort()

print(timestack_names, "\n")
print(timestack_paths, "\n")
print(cumulative_paths, "\n")
print(fod_paths, "\n")

if len(timestack_paths) != len(cumulative_paths) or len(timestack_paths) != len(fod_paths):
    print("We are fucked!")
    
for i in range(len(timestack_paths)):
    filename_op = timestack_names[i]
    filename_op = filename_op.replace("timestack_multimeasure__", "")
    df = pd.read_csv(timestack_paths[i])
    
    # It takes %Area
    red_channel = df.loc[df.index % 2 == 0, df.columns.str.contains("%Area")] # .loc[rows(indices pares), columns(headers que contengan %Area)]
    green_channel = df.loc[df.index % 2 != 0, df.columns.str.contains("%Area")]
    
    # It takes whole areas
    red_channel_areas = df.loc[df.index % 2 == 0, df.columns.str.startswith("Area")]
    green_channel_areas = df.loc[df.index % 2 != 0, df.columns.str.startswith("Area")]
    
    # It calculates the scaled of the %Area
    scaled_red_channel = red_channel_areas.multiply(np.array(red_channel / 100))
    scaled_green_channel = green_channel_areas.multiply(np.array(green_channel / 100))
    red_initial_value = red_channel.iloc[0, red_channel.columns.str.contains("%Area")]
    green_initial_value = green_channel.iloc[0, green_channel.columns.str.contains("%Area")]
    
    # Get normalised cumulative results
    df_cumulative = pd.read_csv(cumulative_paths[i])
    cumulative_percentaje_area = df_cumulative.loc[:, df.columns.str.contains("%Area")]
    cumulative_area = df_cumulative.iloc[:, df.columns.str.startswith("Area")].multiply(np.array(cumulative_percentaje_area / 100))
    first_cumulative = df_cumulative.iloc[0, df.columns.str.contains("%Area")]
    normalised_cumulative = df_cumulative.loc[:, df.columns.str.contains("%Area")] /first_cumulative
    
    # Get first order differences results
    df_fods = pd.read_csv(fod_paths[i])
    raw_fods = df_fods.loc[:, df_fods.columns.str.contains("%Area")]
    fods_area = df_fods.loc[:, df_fods.columns.str.startswith("Area")].multiply(np.array(raw_fods / 100))
    normalised_fods = raw_fods / green_initial_value * 100
    normalised_mean_fods = raw_fods / green_channel.mean() * 100
    mean_fods = normalised_mean_fods.mean()
    #normalised_mean_fods = normalised_mean_fods.T
    # Normalizo todas las filas en función de la primera

    #red_channel.iloc[:, red_channel.columns.str.contains("%Area")] /= red_initial_value
    
    # Normalizo todas las filas en función de la primera
    #green_channel.iloc[:, green_channel.columns.str.contains("%Area")] /= green_initial_value
    
    with pd.ExcelWriter(f"Results_{filename_op}.xlsx") as writer:
        scaled_red_channel.to_excel(writer, sheet_name = "Scaled Red channel")
        scaled_green_channel.to_excel(writer, sheet_name = "Scaled Green channel")
        cumulative_area.to_excel(writer, sheet_name = "Cumulative areas")
        normalised_cumulative.to_excel(writer, sheet_name = "Normalised cumulative")
        fods_area.to_excel(writer, sheet_name = "Fod areas")
        normalised_fods.to_excel(writer, sheet_name = "Normalised fods")
        normalised_mean_fods.to_excel(writer, sheet_name = "Normalised mean fods")
        mean_fods.to_excel(writer, sheet_name = "Mean results(NMF)")
        print("Done! - "+timestack_paths[i])

print("All done!")
    