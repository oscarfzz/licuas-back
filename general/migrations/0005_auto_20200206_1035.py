# Generated by Django 2.2.7 on 2020-02-06 09:35

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0004_auto_20200204_1226'),
    ]

    operations = [
        migrations.AddField(
            model_name='obra',
            name='orden',
            field=models.IntegerField(null=True, verbose_name='orden'),
        ),
        migrations.AlterField(
            model_name='obra',
            name='coste_previsto',
            field=models.DecimalField(decimal_places=2, default=0.0, help_text='importe del coste previsto', max_digits=14, verbose_name='coste previsto'),
        ),
    ]