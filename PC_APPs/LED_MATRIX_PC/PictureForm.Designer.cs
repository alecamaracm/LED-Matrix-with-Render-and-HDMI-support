namespace LED_MATRIX_PC
{
    partial class PictureForm
    {
        /// <summary>
        /// Variable del diseñador necesaria.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpiar los recursos que se estén usando.
        /// </summary>
        /// <param name="disposing">true si los recursos administrados se deben desechar; false en caso contrario.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código generado por el Diseñador de Windows Forms

        /// <summary>
        /// Método necesario para admitir el Diseñador. No se puede modificar
        /// el contenido de este método con el editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.button1 = new System.Windows.Forms.Button();
            this.numericUpDown1 = new System.Windows.Forms.NumericUpDown();
            this.label1 = new System.Windows.Forms.Label();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.button5 = new System.Windows.Forms.Button();
            this.colorDialog1 = new System.Windows.Forms.ColorDialog();
            this.buttonResendHeaders = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.labelRowsUsed = new System.Windows.Forms.Label();
            this.labelSpaceUsed = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.buttonResendAll = new System.Windows.Forms.Button();
            this.label5 = new System.Windows.Forms.Label();
            this.listView1 = new System.Windows.Forms.ListView();
            this.columnHeader1 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader2 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader3 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader4 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader5 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader6 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.imageList1 = new System.Windows.Forms.ImageList(this.components);
            this.buttonAddMedia = new System.Windows.Forms.Button();
            this.buttonRemoveMedia = new System.Windows.Forms.Button();
            this.buttonApplyChanges = new System.Windows.Forms.Button();
            this.openFileDialog2 = new System.Windows.Forms.OpenFileDialog();
            this.label4 = new System.Windows.Forms.Label();
            this.numericUpDownMediaToShow = new System.Windows.Forms.NumericUpDown();
            this.numericUpDownMediaX = new System.Windows.Forms.NumericUpDown();
            this.numericUpDownMediaY = new System.Windows.Forms.NumericUpDown();
            this.label6 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.buttonDisplayMedia = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).BeginInit();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMediaToShow)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMediaX)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMediaY)).BeginInit();
            this.SuspendLayout();
            // 
            // pictureBox1
            // 
            this.pictureBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pictureBox1.Location = new System.Drawing.Point(907, 333);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(435, 328);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox1.TabIndex = 0;
            this.pictureBox1.TabStop = false;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(1144, 104);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(157, 40);
            this.button1.TabIndex = 1;
            this.button1.Text = "Choose picture";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.Button1_Click);
            // 
            // numericUpDown1
            // 
            this.numericUpDown1.Location = new System.Drawing.Point(1233, 162);
            this.numericUpDown1.Maximum = new decimal(new int[] {
            4,
            0,
            0,
            0});
            this.numericUpDown1.Name = "numericUpDown1";
            this.numericUpDown1.Size = new System.Drawing.Size(62, 20);
            this.numericUpDown1.TabIndex = 2;
            this.numericUpDown1.Value = new decimal(new int[] {
            4,
            0,
            0,
            0});
            this.numericUpDown1.ValueChanged += new System.EventHandler(this.NumericUpDown1_ValueChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(1149, 165);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(78, 13);
            this.label1.TabIndex = 3;
            this.label1.Text = "Color bit depth:";
            this.label1.Click += new System.EventHandler(this.Label1_Click);
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            this.openFileDialog1.Filter = "PNG files|*.png|JPG files|*.jpg";
            // 
            // button5
            // 
            this.button5.Location = new System.Drawing.Point(1144, 196);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(157, 40);
            this.button5.TabIndex = 8;
            this.button5.Text = "Redraw picture";
            this.button5.UseVisualStyleBackColor = true;
            this.button5.Click += new System.EventHandler(this.Button5_Click);
            // 
            // buttonResendHeaders
            // 
            this.buttonResendHeaders.Location = new System.Drawing.Point(14, 22);
            this.buttonResendHeaders.Name = "buttonResendHeaders";
            this.buttonResendHeaders.Size = new System.Drawing.Size(106, 26);
            this.buttonResendHeaders.TabIndex = 9;
            this.buttonResendHeaders.Text = "Resend headers";
            this.buttonResendHeaders.UseVisualStyleBackColor = true;
            this.buttonResendHeaders.Click += new System.EventHandler(this.ButtonResendHeaders_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.labelRowsUsed);
            this.groupBox1.Controls.Add(this.labelSpaceUsed);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.progressBar1);
            this.groupBox1.Controls.Add(this.buttonResendAll);
            this.groupBox1.Controls.Add(this.buttonResendHeaders);
            this.groupBox1.Location = new System.Drawing.Point(12, 570);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(641, 91);
            this.groupBox1.TabIndex = 10;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Remote status";
            // 
            // labelRowsUsed
            // 
            this.labelRowsUsed.AutoSize = true;
            this.labelRowsUsed.Font = new System.Drawing.Font("Segoe UI", 11.75F);
            this.labelRowsUsed.Location = new System.Drawing.Point(227, 40);
            this.labelRowsUsed.Name = "labelRowsUsed";
            this.labelRowsUsed.Size = new System.Drawing.Size(76, 21);
            this.labelRowsUsed.TabIndex = 16;
            this.labelRowsUsed.Text = "- - - - - - -";
            // 
            // labelSpaceUsed
            // 
            this.labelSpaceUsed.AutoSize = true;
            this.labelSpaceUsed.Font = new System.Drawing.Font("Segoe UI", 11.75F);
            this.labelSpaceUsed.Location = new System.Drawing.Point(227, 19);
            this.labelSpaceUsed.Name = "labelSpaceUsed";
            this.labelSpaceUsed.Size = new System.Drawing.Size(76, 21);
            this.labelSpaceUsed.TabIndex = 14;
            this.labelSpaceUsed.Text = "- - - - - - -";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Segoe UI", 11.75F, System.Drawing.FontStyle.Underline);
            this.label3.Location = new System.Drawing.Point(136, 19);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(91, 21);
            this.label3.TabIndex = 13;
            this.label3.Text = "Space used:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Segoe UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(492, 55);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(49, 25);
            this.label2.TabIndex = 12;
            this.label2.Text = "-- %";
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(380, 19);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(249, 29);
            this.progressBar1.TabIndex = 11;
            // 
            // buttonResendAll
            // 
            this.buttonResendAll.Location = new System.Drawing.Point(14, 54);
            this.buttonResendAll.Name = "buttonResendAll";
            this.buttonResendAll.Size = new System.Drawing.Size(106, 26);
            this.buttonResendAll.TabIndex = 10;
            this.buttonResendAll.Text = "Resend all";
            this.buttonResendAll.UseVisualStyleBackColor = true;
            this.buttonResendAll.Click += new System.EventHandler(this.ButtonResendAll_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Segoe UI Semibold", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(14, 12);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(118, 20);
            this.label5.TabIndex = 11;
            this.label5.Text = "Media contents:";
            // 
            // listView1
            // 
            this.listView1.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader1,
            this.columnHeader2,
            this.columnHeader3,
            this.columnHeader4,
            this.columnHeader5,
            this.columnHeader6});
            this.listView1.Location = new System.Drawing.Point(16, 43);
            this.listView1.Name = "listView1";
            this.listView1.Size = new System.Drawing.Size(637, 472);
            this.listView1.SmallImageList = this.imageList1;
            this.listView1.TabIndex = 12;
            this.listView1.UseCompatibleStateImageBehavior = false;
            this.listView1.View = System.Windows.Forms.View.Details;
            // 
            // columnHeader1
            // 
            this.columnHeader1.Text = "";
            this.columnHeader1.Width = 106;
            // 
            // columnHeader2
            // 
            this.columnHeader2.Text = "Name";
            this.columnHeader2.Width = 156;
            // 
            // columnHeader3
            // 
            this.columnHeader3.Text = "Type";
            this.columnHeader3.Width = 86;
            // 
            // columnHeader4
            // 
            this.columnHeader4.Text = "Size";
            this.columnHeader4.Width = 84;
            // 
            // columnHeader5
            // 
            this.columnHeader5.Text = "Resolution";
            this.columnHeader5.Width = 102;
            // 
            // columnHeader6
            // 
            this.columnHeader6.Text = "#Frames";
            this.columnHeader6.Width = 73;
            // 
            // imageList1
            // 
            this.imageList1.ColorDepth = System.Windows.Forms.ColorDepth.Depth8Bit;
            this.imageList1.ImageSize = new System.Drawing.Size(100, 50);
            this.imageList1.TransparentColor = System.Drawing.Color.Transparent;
            // 
            // buttonAddMedia
            // 
            this.buttonAddMedia.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonAddMedia.Location = new System.Drawing.Point(15, 524);
            this.buttonAddMedia.Name = "buttonAddMedia";
            this.buttonAddMedia.Size = new System.Drawing.Size(150, 35);
            this.buttonAddMedia.TabIndex = 13;
            this.buttonAddMedia.Text = "Add media";
            this.buttonAddMedia.UseVisualStyleBackColor = true;
            this.buttonAddMedia.Click += new System.EventHandler(this.Button4_Click);
            // 
            // buttonRemoveMedia
            // 
            this.buttonRemoveMedia.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonRemoveMedia.Location = new System.Drawing.Point(171, 524);
            this.buttonRemoveMedia.Name = "buttonRemoveMedia";
            this.buttonRemoveMedia.Size = new System.Drawing.Size(150, 35);
            this.buttonRemoveMedia.TabIndex = 14;
            this.buttonRemoveMedia.Text = "Remove media";
            this.buttonRemoveMedia.UseVisualStyleBackColor = true;
            this.buttonRemoveMedia.Click += new System.EventHandler(this.ButtonRemoveMedia_Click);
            // 
            // buttonApplyChanges
            // 
            this.buttonApplyChanges.Font = new System.Drawing.Font("Segoe UI Semibold", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonApplyChanges.Location = new System.Drawing.Point(504, 524);
            this.buttonApplyChanges.Name = "buttonApplyChanges";
            this.buttonApplyChanges.Size = new System.Drawing.Size(150, 35);
            this.buttonApplyChanges.TabIndex = 15;
            this.buttonApplyChanges.Text = "Apply changes";
            this.buttonApplyChanges.UseVisualStyleBackColor = true;
            // 
            // openFileDialog2
            // 
            this.openFileDialog2.FileName = "openFileDialog2";
            this.openFileDialog2.Filter = "PNG files|*.png|JPG files|*.jpg";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(771, 45);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(86, 13);
            this.label4.TabIndex = 17;
            this.label4.Text = "Media to display:";
            // 
            // numericUpDownMediaToShow
            // 
            this.numericUpDownMediaToShow.Location = new System.Drawing.Point(863, 43);
            this.numericUpDownMediaToShow.Maximum = new decimal(new int[] {
            10000,
            0,
            0,
            0});
            this.numericUpDownMediaToShow.Name = "numericUpDownMediaToShow";
            this.numericUpDownMediaToShow.Size = new System.Drawing.Size(62, 20);
            this.numericUpDownMediaToShow.TabIndex = 16;
            // 
            // numericUpDownMediaX
            // 
            this.numericUpDownMediaX.Location = new System.Drawing.Point(795, 89);
            this.numericUpDownMediaX.Maximum = new decimal(new int[] {
            500,
            0,
            0,
            0});
            this.numericUpDownMediaX.Name = "numericUpDownMediaX";
            this.numericUpDownMediaX.Size = new System.Drawing.Size(62, 20);
            this.numericUpDownMediaX.TabIndex = 18;
            // 
            // numericUpDownMediaY
            // 
            this.numericUpDownMediaY.Location = new System.Drawing.Point(892, 89);
            this.numericUpDownMediaY.Maximum = new decimal(new int[] {
            128,
            0,
            0,
            0});
            this.numericUpDownMediaY.Name = "numericUpDownMediaY";
            this.numericUpDownMediaY.Size = new System.Drawing.Size(62, 20);
            this.numericUpDownMediaY.TabIndex = 19;
            this.numericUpDownMediaY.Value = new decimal(new int[] {
            4,
            0,
            0,
            0});
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(776, 92);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(17, 13);
            this.label6.TabIndex = 20;
            this.label6.Text = "X:";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(873, 92);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(17, 13);
            this.label7.TabIndex = 21;
            this.label7.Text = "Y:";
            // 
            // buttonDisplayMedia
            // 
            this.buttonDisplayMedia.Location = new System.Drawing.Point(795, 124);
            this.buttonDisplayMedia.Name = "buttonDisplayMedia";
            this.buttonDisplayMedia.Size = new System.Drawing.Size(157, 40);
            this.buttonDisplayMedia.TabIndex = 22;
            this.buttonDisplayMedia.Text = "Display";
            this.buttonDisplayMedia.UseVisualStyleBackColor = true;
            this.buttonDisplayMedia.Click += new System.EventHandler(this.ButtonDisplayMedia_Click);
            // 
            // PictureForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1363, 673);
            this.Controls.Add(this.buttonDisplayMedia);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.numericUpDownMediaY);
            this.Controls.Add(this.numericUpDownMediaX);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.numericUpDownMediaToShow);
            this.Controls.Add(this.buttonApplyChanges);
            this.Controls.Add(this.buttonRemoveMedia);
            this.Controls.Add(this.buttonAddMedia);
            this.Controls.Add(this.listView1);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.button5);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.numericUpDown1);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.pictureBox1);
            this.Name = "PictureForm";
            this.Text = "Media contents";
            this.Load += new System.EventHandler(this.PictureForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMediaToShow)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMediaX)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMediaY)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.NumericUpDown numericUpDown1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.Button button5;
        private System.Windows.Forms.ColorDialog colorDialog1;
        private System.Windows.Forms.Button buttonResendHeaders;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label labelSpaceUsed;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ProgressBar progressBar1;
        private System.Windows.Forms.Button buttonResendAll;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.ListView listView1;
        private System.Windows.Forms.ImageList imageList1;
        private System.Windows.Forms.ColumnHeader columnHeader1;
        private System.Windows.Forms.ColumnHeader columnHeader2;
        private System.Windows.Forms.ColumnHeader columnHeader3;
        private System.Windows.Forms.ColumnHeader columnHeader4;
        private System.Windows.Forms.ColumnHeader columnHeader5;
        private System.Windows.Forms.ColumnHeader columnHeader6;
        private System.Windows.Forms.Button buttonAddMedia;
        private System.Windows.Forms.Button buttonRemoveMedia;
        private System.Windows.Forms.Button buttonApplyChanges;
        private System.Windows.Forms.OpenFileDialog openFileDialog2;
        private System.Windows.Forms.Label labelRowsUsed;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.NumericUpDown numericUpDownMediaToShow;
        private System.Windows.Forms.NumericUpDown numericUpDownMediaX;
        private System.Windows.Forms.NumericUpDown numericUpDownMediaY;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button buttonDisplayMedia;
    }
}

