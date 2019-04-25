# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
En Q&A sida.  
Man loggar in.  
Man ställer frågor till en användare.  
Användaren kan svara på eller ta bort frågor.  
Se frågor ställda till en själv samt frågor ställda av dig.  

## 2. Vyer (sidor)
Login sida (Första man ser)  
Registrering  
En profilsida med ställda frågor + svar  
Sida med mottagna frågor  
Sida med alla användare man kan fråga + möjlighet att ställa frågan  
Error sidor, 404, 500, autentisering misslyckades samt en vy för oväntade fel.  

## 3. Funktionalitet (med sekvensdiagram)
Se ./Diagram/Sekvens

## 4. Arkitektur (Beskriv filer och mappar)
slutprojekt19webbserver  
--.git  
--Database  
----model.rb  
----qna.db  
--Diagram  
----ER  
------ERslutprojekt.drawio  
----Sekvens  
------AnswerQuestion.PNG  
------AskingQuestion.PNG  
------SucessfulLogin.PNG  
--Public  
--Views  
----Error  
------error_404.slim  
------error_500.slim  
------error_auth.slim  
------error.slim  
----Layout  
------layout.slim  
----Profile  
------login.slim  
------profile.slim  
------register.slim  
----Questions  
------browse.slim  
------recieved.slim  
--controller.rb  
--README.md  

## 5. (Databas med ER-diagram)
Se ./Diagram/ER
