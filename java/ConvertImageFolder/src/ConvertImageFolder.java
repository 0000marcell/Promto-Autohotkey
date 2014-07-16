import javax.swing.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JOptionPane;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class ConvertImageFolder{
	JProgressBar progressBar;
	JFrame frame;
	int itemPercentage; // Porcentagem de cada item
	int imageWidth;
	int imageHeight;
	JTextField widthField;
	JTextField heightField;
	String imageFolder;

	public static void main( String args[]){
		// ConvertImageFolder convertImage = new ConvertImageFolder();
		// Init the gui
		new ConvertImageFolder().gui();
		// convertImage.gui();
	}

	public void startConvertion(){
		// Loop though all the files in that folder
		imageWidth = Integer.parseInt(widthField.getText());
		imageHeight = Integer.parseInt(heightField.getText());
		ConvertImageFolder convertImage = new ConvertImageFolder(); 

		if(imageWidth == 0 || imageHeight == 0){
			JOptionPane.showMessageDialog(null, 
	    		"Digite os valores de altura e largura antes de continuar!", 
	    		"Erro", 
	  		JOptionPane.INFORMATION_MESSAGE);	
			return;
		}

		File[] files = new File(imageFolder).listFiles();
		System.out.println("number of items "+files.length);
		convertImage.setItemPercentage(files.length);
	  for (File file : files) {
	    if (file.isDirectory()){
	    	JOptionPane.showMessageDialog(null, 
	    		"Existem outras subpastas, fotos nessas subpastas nao serao convertidas ", 
	    		"Informacao", 
	  		JOptionPane.INFORMATION_MESSAGE);
	    }else{
	    	convertImage.convertImage(imageFolder, file.getName());  	
	    	convertImage.changeProgress();
	    }
	  }
	  convertImage.finish();
	}

	public void setItemPercentage(int filesCount){
		itemPercentage = 100/filesCount;
		System.out.println("result of the division "+itemPercentage);
	}

	public void gui(){
		// Get image folder
		imageFolder = new ConvertImageFolder().getImageFolder();
		JOptionPane.showMessageDialog(null, "Pasta de imagem "+imageFolder, "Informacao", 
	  		JOptionPane.INFORMATION_MESSAGE);


		frame = new JFrame("Convertendo Imagens"); 
		JPanel mainPanel = new JPanel();
		JLabel infoLabel = new JLabel("Tamanho padrao do programa: 448 x 336");
		JLabel widthLabel = new JLabel("Largura");
		JLabel heightLabel = new JLabel("Altura");
		widthField = new JTextField();
		heightField = new JTextField();
		int marginLeft = 40;
		JButton startConvertionButton = new JButton("Converter imagens");

		progressBar = new JProgressBar(0, 100);
    progressBar.setValue(0);
    progressBar.setStringPainted(true);
		mainPanel.setBounds(0, 0, 280, 180);
		infoLabel.setBounds(10+marginLeft, 10, 100, 20);
		widthLabel.setBounds(10+marginLeft, 35, 100, 20);
		heightLabel.setBounds(10+marginLeft, 60, 100, 20);
		widthField.setBounds(115+marginLeft, 35, 50, 20);
		heightField.setBounds(115+marginLeft, 60, 50, 20);
		startConvertionButton.setBounds(10+marginLeft, 85, 150, 30);
		startConvertionButton.addActionListener(new ConvertImageFolder.startConvertionButton());
		progressBar.setBounds(10, 120, 250, 30);

		mainPanel.setLayout(null);

		mainPanel.add(infoLabel);
		mainPanel.add(widthLabel);
		mainPanel.add(heightLabel);
		mainPanel.add(widthField);
		mainPanel.add(heightField);
		mainPanel.add(startConvertionButton);
		mainPanel.add(progressBar);
		frame.add(mainPanel);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setSize(280, 180);
		frame.setVisible(true);
	}

	public void finish(){
		frame.dispose();
	}

	public class startConvertionButton implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			ConvertImageFolder convertImage = new ConvertImageFolder(); 
			convertImage.startConvertion();
		}
	}

	public void changeProgress(){
		progressBar.setValue(progressBar.getValue()+itemPercentage);
	}

	public void convertImage(String imageFolder, String fileName){
		BufferedImage bufferedImage;
 		BufferedImage newBufferedImage;
 		Image image;
		try {
	  	//read image file
	  	String imagePath = imageFolder+"/"+fileName;
	  	bufferedImage = ImageIO.read(new File(imagePath));
	  	//Resize the image
 			image = bufferedImage.getScaledInstance(imageWidth, imageHeight, Image.SCALE_DEFAULT);
		  // create a blank, RGB, same width and height, and a white background
	  	newBufferedImage = new BufferedImage(imageWidth,
			imageHeight, BufferedImage.TYPE_INT_RGB);
	  	newBufferedImage.createGraphics().drawImage(image, 0, 0, Color.WHITE, null);
	  	// write to jpeg file

	  	ImageIO.write(newBufferedImage, "jpg", new File(imageFolder+"/a_"+fileName));
	  	// JOptionPane.showMessageDialog(null, "A imagem foi convertida e inserida! ", "Informacao", 
	  		// JOptionPane.INFORMATION_MESSAGE);
		} catch (IOException e) {
 			JOptionPane.showMessageDialog(null, e.toString(), "Erro", JOptionPane.ERROR_MESSAGE);
		}
	}

	public String getImageFolder(){
		String returnValue = null;
		String line;
		try{
			BufferedReader reader = new BufferedReader(new FileReader("temp/folder_convert_info.txt"));
			while ((line = reader.readLine()) != null){
				returnValue = line;
    	}
    	reader.close(); 
		}catch(Exception e){
			JOptionPane.showMessageDialog(null, e.toString(), "Erro", JOptionPane.ERROR_MESSAGE);
		}
		return returnValue;
	}
}
