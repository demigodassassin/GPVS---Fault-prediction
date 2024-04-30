import pandas as pd
import streamlit as st 
# import numpy as np

from sqlalchemy import create_engine
import pickle, joblib

pd.set_option("styler.render.max_elements", 100000)
model1 = pickle.load(open('best_model.pkl', 'rb'))
impute = joblib.load('impute')
winsor = joblib.load('winzor')
minmax = joblib.load('scale')

def predict_MPG(data, user, pw, db):

    engine = create_engine(f"mysql+pymysql://{user}:{pw}@localhost/{db}")


    clean = pd.DataFrame(impute.transform(data), columns=data.select_dtypes(exclude = ['object']).columns)
    clean1 = winsor.transform(clean)
    clean2 = pd.DataFrame(minmax.transform(clean1))
    prediction = pd.DataFrame(model1.predict(clean2), columns = ['Predict_Fault'])
    
    final = pd.concat([prediction,data], axis = 1)
    final.to_sql('solar_prediction', con = engine, if_exists = 'replace', chunksize = 1000, index = False)
    
    return final

def main():
    

    st.title("GPVS-Fault prediction")
    st.sidebar.title("GPVS-Fault prediction")

    # st.radio('Type of Cab you want to Book', options=['Mini', 'Sedan', 'XL', 'Premium', 'Rental'])
    html_temp = """
    <div style="background-color:tomato;padding:10px">
    <h2 style="color:white;text-align:center;">GPVS-Faults  Prediction App </h2>
    </div>
    
    """
    st.markdown(html_temp, unsafe_allow_html = True)
    st.text("")
    

    uploadedFile = st.sidebar.file_uploader("Choose a file", type=['csv','xlsx'], accept_multiple_files=False, key="fileUploader")
    if uploadedFile is not None :
        try:

            data = pd.read_csv(uploadedFile)
        except:
                try:
                    data = pd.read_excel(uploadedFile)
                except:      
                    data = pd.DataFrame()
        
        
    else:
        st.sidebar.warning("You need to upload a CSV or an Excel file.")
    
    html_temp = """
    <div style="background-color:tomato;padding:10px">
    <p style="color:white;text-align:center;">Add DataBase Credientials </p>
    </div>
    """
    st.sidebar.markdown(html_temp, unsafe_allow_html = True)
            
    user = st.sidebar.text_input("user", "Type Here")
    pw = st.sidebar.text_input("password", "Type Here")
    db = st.sidebar.text_input("database", "Type Here")
    
    result = ""
    
    if st.button("Predict"):
        result = predict_MPG(data, user, pw, db)
        st.dataframe(result) 
        #st.table(result.style.set_properties(**{'background-color': 'white','color': 'black'}))
                           
        import seaborn as sns
        cm = sns.light_palette("blue", as_cmap = True)
        st.table(result.style.background_gradient(cmap=cm))#.set_precision(2))

if __name__=='__main__':
    main()

